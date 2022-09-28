// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';
import './IFriendlyBetCallback.sol';

contract WeatherAPIConsumer is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    bytes32 private jobId;
    uint256 private fee;
    mapping (bytes32 => address) private callbackMap;

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
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestTemperatureData(address _callback) public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        // Set the URL to perform the GET request on
        req.add('get', 'https://mocki.io/v1/2755e1e1-eef5-4d54-9110-7d6568ff7c06');
        // Set the path to find the desired data in the API response, where the response format is:
        // {"maxTemperature": temperature_data}
        req.add('path', 'maxTemperature');
        // Multiply the result by 1000 to remove decimals
        req.addInt('times', 1000);
        // Sends the request
        requestId = sendChainlinkRequest(req, fee);
        // Register callback
        callbackMap[requestId] = _callback;
    }

    /**
     * Receive the response in the form of uint256
     */
    function fulfill(bytes32 _requestId, uint256 _maxTemperature) public recordChainlinkFulfillment(_requestId) {
        IFriendlyBetCallback(callbackMap[_requestId]).onReceiveTemperature(_maxTemperature);
    }

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }
}