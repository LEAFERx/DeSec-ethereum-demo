// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.7;

contract DNSRegistry {

    // Declare state variables of the contract
    address payable public owner;
    mapping (string => address) public registry;

    // When 'DNSRegistry' contract is deployed, set owner to the creator of the contract
    constructor() {
        owner = payable(msg.sender);
    }

    // Consumers can pay >= 1 ether to register their domain. Donations are welcome.
    function registerDomain(string memory domain) public payable {
        require(msg.value >=  1 ether, "You must pay at least 1 ETH per domain registration");
        require(register[domain] == address(0), "Sorry, this domain is already taken.")
        registry[domain] = msg.sender;
        owner.transfer(msg.value);
    }

}




