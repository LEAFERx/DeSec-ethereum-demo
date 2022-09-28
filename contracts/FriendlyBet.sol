// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import './IFriendlyBetCallback.sol';
import './WeatherAPIConsumer.sol';

contract FriendlyBet is IFriendlyBetCallback {
    // Declare state variables of the contract
    address public party1;
    address public party2;
    uint256 public betAmount;
    WeatherAPIConsumer public apiConsumer;
    uint256 public betTemperatureThreshold;

    event BetJoined(address indexed party, uint64 partyIdx);
    event BetEstablished(address indexed party1, address indexed party2, bytes32 requestId);
    event BetExecuted(address indexed winner, uint256 temperature);

    constructor(address consumerAddress) {
        betAmount = 5;
        betTemperatureThreshold = 70 * 1000; // units of API consumer are * 1000
        apiConsumer = WeatherAPIConsumer(consumerAddress);
    }

    // How many parties are currently in the bet
    function activeParties() public view returns (uint64) {
        uint64 active = 0;
        if (party1 != address(0)) {
            active += 1;
        } 
        if (party2 != address(0)) {
            active += 1;
        }
        return active;
    }

    modifier notInBet {
        require(msg.sender != party1 && msg.sender != party2, "Already in bet.");
        _;
    }

    modifier betNotFull {
        require(activeParties() < 2, "Bet is full.");
        _;
    }

    function joinBet() public payable notInBet betNotFull {
        require(msg.value >= betAmount * 0.001 ether, "You must send at least betAmount to join the bet.");
        if (activeParties() == 0) {
            party1 = msg.sender;
            emit BetJoined(msg.sender, 1);
        } else {
            party2 = msg.sender;
            emit BetJoined(msg.sender, 2);
            // We have two parties now. Bet is established.
            bytes32 requestId = apiConsumer.requestTemperatureData(address(this));
            emit BetEstablished(party1, party2, requestId);
        }
        payable(msg.sender).transfer(msg.value - betAmount * 0.001 ether); // refund the difference
    }

    modifier onlyAPIConsumer {
        require(msg.sender == address(apiConsumer), "Only API consumer can trigger");
        _;
    }

    function onReceiveTemperature(uint256 _temperature) external override onlyAPIConsumer {
        // Decide the winner
        address winner = _temperature > betTemperatureThreshold ? party1 : party2;
        uint256 winningAmount = 2 * betAmount;
        emit BetExecuted(winner, _temperature);
        // Clean up states
        party1 = address(0);
        party2 = address(0);
        // Send out the prize
        payable(winner).transfer(winningAmount * 0.001 ether);
    }
}
