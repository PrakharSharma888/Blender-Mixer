// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Mixer {
    // Mapping to store the balances of each address
    mapping(address => uint) public balances;

    uint256 public count = 0;

    // Mapping to store the anonymous addresses for each user
    mapping(address => address) public anonymousAddresses;

    // Event to emit when a user mixes their tokens
    event Mix(address indexed from, address indexed to, uint amount);

    address[] public anonymousAddressList;

    // Fallback function to receive ether
    function entry() external payable {
        require(msg.value > 0, "Cannot send 0 or negative value");
        balances[msg.sender] += msg.value;
        count++;
    }

    // Function to mix the tokens of a user
    function mix(uint amount) public payable {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(amount > 0, "Cannot send 0 or negative value");
        uint randomNumber = newAddress();
        address anonymousAddress = anonymousAddressGeneration(randomNumber);
        balances[anonymousAddress] += amount;
        balances[msg.sender] -= amount;
        anonymousAddresses[msg.sender] = anonymousAddress;
        emit Mix(msg.sender, anonymousAddress, amount);
    }

    // Function to retrieve the mixed tokens of a user
    function retrieve(address anonymousAddress, uint amount) public {
        require(anonymousAddresses[msg.sender] == anonymousAddress, "Invalid anonymous address");
        require(balances[anonymousAddress] >= amount, "Insufficient balance");
        require(amount > 0, "Cannot send 0 or negative value");
        balances[anonymousAddress] -= amount;
        balances[msg.sender] += amount;
        emit Mix(anonymousAddress, msg.sender, amount);
    }

    // Function to generate a new anonymous address
    function newAddress() private view returns (uint) {
        uint random = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, count)));
        return random;
    }

    function anonymousAddressGeneration(uint _index) view public returns(address){
        return anonymousAddressList[_index];
    }
}