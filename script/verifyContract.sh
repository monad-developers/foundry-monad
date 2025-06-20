#!/bin/bash

# Contract verification script for Monad network
# Usage: bash verifyContract.sh <contract_address> <source_file:contract_name> [constructor_args] [api_key]
# Example: bash verifyContract.sh 0x4F826CDf1eac05d05aEC62EDC87EE3753e9440b5 src/CampaignFactory.sol:CampaignFactory $(cast abi-encode "constructor(address,address)" 0x66661860a6C83c51C4F6eFAb07E3E80Eb194514D 0x25daAde2d1B6a36A7f551C971B76964Bc0a49504) your_api_key

if [ $# -lt 2 ] || [ $# -gt 4 ]; then
    echo "Wrong argument count"
    echo "Usage: bash verifyContract.sh <contract_address> <source_file:contract_name> [constructor_args] [api_key]"
    echo "Note: If api_key is not provided, ETHERSCAN_API_KEY environment variable will be used"
    exit 1
fi

CONTRACT_ADDRESS="$1"
SOURCE_FILE="$2"
CONSTRUCTOR_ARGS="$3"
API_KEY="$4"

# Use provided API key or fall back to environment variable
if [ -n "$API_KEY" ]; then
    ETHERSCAN_API_KEY="$API_KEY"
elif [ -z "$ETHERSCAN_API_KEY" ]; then
    echo "Error: No API key provided. Either pass it as 4th argument or set ETHERSCAN_API_KEY environment variable"
    exit 1
fi

# Build the base arguments
BASE_ARGS="$CONTRACT_ADDRESS $SOURCE_FILE"

# Add constructor args if provided
if [ -n "$CONSTRUCTOR_ARGS" ]; then
    ADDITIONAL_ARGS="--constructor-args $CONSTRUCTOR_ARGS $BASE_ARGS"
else
    ADDITIONAL_ARGS="$BASE_ARGS"
fi

echo "Verifying contract with args: $ADDITIONAL_ARGS"

echo "Verifying on Etherscan..."
forge verify-contract \
--watch \
--etherscan-api-key $ETHERSCAN_API_KEY \
--verifier-url "https://api.etherscan.io/api?chainid=10143" \
--chain-id 10143 \
$ADDITIONAL_ARGS

echo "Verifying on Monad Explorer..."
forge verify-contract \
--watch \
--verifier sourcify \
--verifier-url 'https://sourcify-api-monad.blockvision.org' \
--chain-id 10143 \
$ADDITIONAL_ARGS

echo "Verifying on Socialscan..."
forge verify-contract \
--watch \
--verifier etherscan \
--verifier-url 'https://api.socialscan.io/monad-testnet/v1/explorer/command_api/contract' \
--etherscan-api-key $ETHERSCAN_API_KEY \
--chain 10143 \
$ADDITIONAL_ARGS 