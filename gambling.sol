// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

contract FriendlyBet {

    // Declare state variables of the contract
    address payable public party1;
    address payable public party2;
    uint256 public betAmount;
    bool completedBet;

    // When 'VendingMachine' contract is deployed:
    // 1. set the deploying address as the owner of the contract
    // 2. set the deployed smart contract's cupcake balance to 100
    constructor() {
        party1 = payable(0xEd81c1feb82cE8eD831b07b3338627FaF67576A8); // Zhe
        party2 = payable(0xEbaB521a59c292CD0D84b50fB5dA408a8eD45363); // Akshit
        completedBet = false;
        betAmount = 5;
    }

    function joinBet(address payable addr) public payable {
        require(addr == party1 || addr == party2, "Only one of the two parties (Akshit or Zhe) can join this bet.");
        require(msg.sender == addr, "You must be one of the parties involved in the bet.");
        require(msg.value >= betAmount * 0.001 ether, "You must send at least betAmount to join the bet.");
        addr.transfer(msg.value - betAmount * 0.001 ether); // refund the difference
    }

    function executeBet() public {
        bool eventHappened = true;
        address payable winner = eventHappened ? party1 : party2;
        uint256 winningAmount = 2 * betAmount;
        winner.transfer(winningAmount);
        completedBet = true;
    }
}

