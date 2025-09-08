// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleImplementation {
    // Storage variables
    uint256 public value;
    address public owner;
    bool public initialized;
    
    // Events
    event ValueChanged(uint256 newValue);
    event OwnerChanged(address newOwner);
    
    // Modifier to check if caller is owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    // Initialize function (replaces constructor for proxy pattern)
    function initialize(address _owner) external {
        require(!initialized, "Already initialized");
        owner = _owner;
        value = 0;
        initialized = true;
    }
    
    // Set a new value
    function setValue(uint256 _value) external onlyOwner {
        value = _value;
        emit ValueChanged(_value);
    }
    
    // Increment the value
    function increment() external {
        value++;
        emit ValueChanged(value);
    }
    
    // Get the current value
    function getValue() external view returns (uint256) {
        return value;
    }
    
    // Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
        emit OwnerChanged(newOwner);
    }
} 