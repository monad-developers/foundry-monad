// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";

/// @title Counter Deployment Script
/// @notice This script deploys a new Counter contract to the network
contract CounterScript is Script {
    /// @notice Custom error for missing private key
    error MissingPrivateKey();

    /// @notice Setup function that runs before the main deployment
    function setUp() public {}

    /// @notice Main deployment function
    /// @dev Requires PRIVATE_KEY environment variable to be set
    function run() public {
        // Get deployer private key from environment
        uint256 deployerPrivateKey;
        try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
            deployerPrivateKey = key;
        } catch {
            console.error("Error: PRIVATE_KEY environment variable not set");
            console.error("Please set your private key using: export PRIVATE_KEY=your_private_key");
            revert MissingPrivateKey();
        }

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the Counter contract
        Counter counter = new Counter();
        console.log("Counter deployed at:", address(counter));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
