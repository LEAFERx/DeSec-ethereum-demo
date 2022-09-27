// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;


import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';


contract FriendlyBet {

    // Declare state variables of the contract
    address payable public party1;
    address payable public party2;
    uint256 public betAmount;
    bool completedBet;
    WeatherAPIConsumer public apiConsumer;
    uint256 public betTemperatureThreshold;

    // When 'FriendlyBet' contract is deployed, set the addresses of the two parties (can be specified as arguments)
    // and initialize state variables.
    constructor(address consumerAddress) {
        party1 = payable(0xEd81c1feb82cE8eD831b07b3338627FaF67576A8); // Zhe
        party2 = payable(0xEbaB521a59c292CD0D84b50fB5dA408a8eD45363); // Akshit
        completedBet = false;
        betAmount = 5;
        betTemperatureThreshold = 70 * 1000; // units of API consumer are * 1000
        apiConsumer = WeatherAPIConsumer(consumerAddress);
        apiConsumer.requestTemperatureData();
    }

    function joinBet(address payable addr) public payable {
        require(addr == party1 || addr == party2, "Only one of the two parties (Akshit or Zhe) can join this bet.");
        require(msg.sender == addr, "You must be one of the parties involved in the bet.");
        require(msg.value >= betAmount * 0.001 ether, "You must send at least betAmount to join the bet.");
        addr.transfer(msg.value - betAmount * 0.001 ether); // refund the difference
    }

    function executeBet() public {
        require(apiConsumer.isFulfilled(), "Weather data has not been populated yet.");
        uint256 maxTemperature = apiConsumer.getTemperature();
        address payable winner = maxTemperature > betTemperatureThreshold ? party1: party2;
        uint256 winningAmount = 2 * betAmount;
        winner.transfer(winningAmount);
        completedBet = true;
    }
}

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * THIS EXAMPLE USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract WeatherAPIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 public maxTemperature;
    bytes32 private jobId;
    uint256 private fee;
    bool public fulfilled;

    event RequestTemperature(bytes32 indexed requestId, uint256 maxTemperature);

    /**
     * @notice Initialize the link token and target oracle
     *
     * Goerli Testnet details:
     * Link Token: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Oracle: 0xCC79157eb46F5624204f47AB42b3906cAA40eaB7 (Chainlink DevRel)
     * jobId: ca98366cc7314957b8c012c72f05aeeb
     *
     */
    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0xCC79157eb46F5624204f47AB42b3906cAA40eaB7);
        jobId = 'ca98366cc7314957b8c012c72f05aeeb';
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0,1 * 10**18 (Varies by network and job)
        fulfilled = false;
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestTemperatureData() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Set the URL to perform the GET request on
        // req.add('get', 'https://archive-api.open-meteo.com/v1/era5?latitude=37.87&longitude=57.73&start_date=2022-09-15&end_date=2022-09-15&daily=temperature_2m_max,temperature_2m_min&timezone=America%2FNew_York&temperature_unit=fahrenheit');
        req.add('get', 'https://mocki.io/v1/2755e1e1-eef5-4d54-9110-7d6568ff7c06');
        // Set the path to find the desired data in the API response, where the response format is:
        // {"temperature_2m_max": [array of temperatures]}
        // request.add("path", "RAW.ETH.USD.VOLUME24HOUR"); // Chainlink nodes prior to 1.0.0 support this format
        // req.add('path', 'temperature_2m_max,0'); // Chainlink nodes 1.0.0 and later support this format
        req.add('path', 'maxTemperature');
        // Multiply the result by 1000000000000000000 to remove decimals
        // int256 timesAmount = 10**18;
        req.addInt('times', 1000);

        // Sends the request
        return sendChainlinkRequest(req, fee);
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(bytes32 _requestId, uint256 _maxTemperature) public recordChainlinkFulfillment(_requestId) {
        emit RequestTemperature(_requestId, _maxTemperature);
        maxTemperature = _maxTemperature;
        fulfilled = true;
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }

    function getTemperature() public view returns (uint256) {
        return maxTemperature;
    }

    function isFulfilled() public view returns (bool) {
        return fulfilled;
    }
}
