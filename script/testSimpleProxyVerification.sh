#!/bin/bash

# Test simple proxy verification script for Monad network
# This script uses simple custom proxy contracts instead of OpenZeppelin
# Usage: bash testSimpleProxyVerification.sh

# Environment variables (set before running)
if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY environment variable not set"
    echo "Usage: PRIVATE_KEY=your_key ETHERSCAN_API_KEY=your_key bash testSimpleProxyVerification.sh"
    exit 1
fi

if [ -z "$ETHERSCAN_API_KEY" ]; then
    echo "Error: ETHERSCAN_API_KEY environment variable not set"
    echo "Usage: PRIVATE_KEY=your_key ETHERSCAN_API_KEY=your_key bash testSimpleProxyVerification.sh"
    exit 1
fi

DEPLOYER_ADDRESS="0xD7702541b1D17F823F367B1643dc2cC86c4fD68C"

# Generate random suffix for test contracts (macOS compatible)
RANDOM_SUFFIX=$(date +%s)$(jot -r 1 1000 9999)
IMPL_CONTRACT_NAME="SimpleImplementation${RANDOM_SUFFIX}"
PROXY_CONTRACT_NAME="SimpleProxy${RANDOM_SUFFIX}"
IMPL_FILE="src/${IMPL_CONTRACT_NAME}.sol"
PROXY_FILE="src/${PROXY_CONTRACT_NAME}.sol"
IMPL_SOURCE_FILE="${IMPL_FILE}:${IMPL_CONTRACT_NAME}"
PROXY_SOURCE_FILE="${PROXY_FILE}:${PROXY_CONTRACT_NAME}"

echo "=========================================="
echo "🧪 SIMPLE PROXY VERIFICATION TEST"
echo "=========================================="
echo "Implementation Contract: $IMPL_CONTRACT_NAME"
echo "Proxy Contract: $PROXY_CONTRACT_NAME"
echo "Implementation File: $IMPL_FILE"
echo "Proxy File: $PROXY_FILE"
echo "Using hardcoded private key"
echo "=========================================="

# Step 1: Create a custom implementation contract
echo ""
echo "🔧 [1/6] CREATING CUSTOM IMPLEMENTATION CONTRACT..."
echo "=========================================="

# Generate random function names and values (macOS compatible)
IMPL_FUNC1_NAME="implRandomFunction$(jot -r 1 100 999)"
IMPL_FUNC2_NAME="implTestFunction$(jot -r 1 100 999)"
IMPL_FUNC3_NAME="implDummyFunction$(jot -r 1 100 999)"
RANDOM_VALUE1=$(jot -r 1 1 1000)
RANDOM_VALUE2=$(jot -r 1 1001 2000)
RANDOM_VALUE3=$(jot -r 1 2001 3000)

# Create implementation contract with random elements
cat > "$IMPL_FILE" << EOF
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ${IMPL_CONTRACT_NAME} {
    // Storage variables
    uint256 public value;
    address public owner;
    bool public initialized;
    
    // Random storage for uniqueness
    uint256 public randomValue = ${RANDOM_VALUE1};
    
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
    
    // Random functions to make this contract unique
    function ${IMPL_FUNC1_NAME}() public pure returns (uint256) {
        return ${RANDOM_VALUE1};
    }

    function ${IMPL_FUNC2_NAME}(uint256 _input) public pure returns (uint256) {
        return _input + ${RANDOM_VALUE2};
    }

    function ${IMPL_FUNC3_NAME}() public view returns (string memory) {
        return "Impl test function ${RANDOM_VALUE3}";
    }

    // Random function for uniqueness
    function getRandomValue() external view returns (uint256) {
        return randomValue;
    }
}
EOF

echo "✅ Created implementation contract: $IMPL_CONTRACT_NAME"
echo "📄 Added random implementation functions: $IMPL_FUNC1_NAME, $IMPL_FUNC2_NAME, $IMPL_FUNC3_NAME"

# Step 2: Create a simple proxy contract
echo ""
echo "🔧 [2/6] CREATING SIMPLE PROXY CONTRACT..."
echo "=========================================="

# Generate random function names and values for proxy (macOS compatible)
PROXY_FUNC1_NAME="proxyRandomFunction$(jot -r 1 100 999)"
PROXY_FUNC2_NAME="proxyTestFunction$(jot -r 1 100 999)"
PROXY_FUNC3_NAME="proxyDummyFunction$(jot -r 1 100 999)"
PROXY_VALUE1=$(jot -r 1 3001 4000)
PROXY_VALUE2=$(jot -r 1 4001 5000)
PROXY_VALUE3=$(jot -r 1 5001 6000)

cat > "$PROXY_FILE" << EOF
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ${PROXY_CONTRACT_NAME} {
    // Storage slot for implementation address
    // keccak256("IMPLEMENTATION_SLOT") - 1
    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    
    // Storage slot for admin address
    // keccak256("ADMIN_SLOT") - 1
    bytes32 private constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
    
    // Events
    event ImplementationChanged(address newImplementation);
    event AdminChanged(address newAdmin);
    
    // Modifier to check if caller is admin
    modifier onlyAdmin() {
        require(msg.sender == getAdmin(), "Not the admin");
        _;
    }
    
    constructor(address _implementation, address _admin) {
        _setImplementation(_implementation);
        _setAdmin(_admin);
    }
    
    // Fallback function - delegates all calls to implementation
    fallback() external payable {
        _delegate();
    }
    
    // Receive function for ETH transfers
    receive() external payable {
        _delegate();
    }
    
    // Get current implementation address
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }
    
    // Get current admin address
    function getAdmin() public view returns (address) {
        return _getAdmin();
    }
    
    // Upgrade to new implementation (only admin)
    function upgrade(address newImplementation) external onlyAdmin {
        _setImplementation(newImplementation);
        emit ImplementationChanged(newImplementation);
    }
    
    // Change admin (only current admin)
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "Invalid admin address");
        _setAdmin(newAdmin);
        emit AdminChanged(newAdmin);
    }
    
    // Random functions to make this proxy unique
    function ${PROXY_FUNC1_NAME}() external pure returns (uint256) {
        return ${PROXY_VALUE1};
    }

    function ${PROXY_FUNC2_NAME}(uint256 _input) external pure returns (uint256) {
        return _input + ${PROXY_VALUE2};
    }

    function ${PROXY_FUNC3_NAME}() external view returns (string memory) {
        return "Proxy test function ${PROXY_VALUE3}";
    }

    // Random function for uniqueness
    function proxyVersion() external pure returns (string memory) {
        return "SimpleProxyV${RANDOM_SUFFIX}";
    }
    
    // Internal function to delegate calls
    function _delegate() internal {
        address implementation = _getImplementation();
        require(implementation != address(0), "No implementation set");
        
        assembly {
            // Copy calldata to memory
            calldatacopy(0, 0, calldatasize())
            
            // Delegate call to implementation
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)
            
            // Copy return data to memory
            returndatacopy(0, 0, returndatasize())
            
            // Return or revert based on result
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
    
    // Internal function to get implementation address
    function _getImplementation() internal view returns (address implementation) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            implementation := sload(slot)
        }
    }
    
    // Internal function to set implementation address
    function _setImplementation(address implementation) internal {
        require(implementation != address(0), "Invalid implementation address");
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, implementation)
        }
    }
    
    // Internal function to get admin address
    function _getAdmin() internal view returns (address admin) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            admin := sload(slot)
        }
    }
    
    // Internal function to set admin address
    function _setAdmin(address admin) internal {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            sstore(slot, admin)
        }
    }
}
EOF

echo "✅ Created proxy contract: $PROXY_CONTRACT_NAME"
echo "📄 Added random proxy functions: $PROXY_FUNC1_NAME, $PROXY_FUNC2_NAME, $PROXY_FUNC3_NAME"

# Show preview of both contracts
echo ""
echo "📄 Implementation contract preview (last 10 lines):"
tail -10 "$IMPL_FILE"

echo ""
echo "📄 Proxy contract preview (last 10 lines):"
tail -10 "$PROXY_FILE"

# Step 3: Compile the contracts
echo ""
echo "🔨 [3/6] COMPILING CONTRACTS..."
echo "=========================================="

if ! forge build --skip test; then
    echo "💥 COMPILATION FAILED!"
    echo "Cleaning up..."
    rm -f "$IMPL_FILE" "$PROXY_FILE"
    exit 1
fi

echo "✅ Compilation successful!"

# Step 4: Deploy the implementation contract
echo ""
echo "📦 [4/6] DEPLOYING IMPLEMENTATION CONTRACT..."
echo "=========================================="

IMPL_DEPLOY_CMD="forge create $IMPL_SOURCE_FILE --private-key $PRIVATE_KEY --broadcast"
echo "Running: forge create $IMPL_SOURCE_FILE --private-key [HIDDEN] --broadcast"
echo ""

IMPL_DEPLOY_OUTPUT=$(eval "$IMPL_DEPLOY_CMD" 2>&1)
IMPL_DEPLOY_EXIT_CODE=$?

echo "$IMPL_DEPLOY_OUTPUT"

if [ $IMPL_DEPLOY_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "💥 IMPLEMENTATION DEPLOYMENT FAILED!"
    echo "Cleaning up..."
    rm -f "$IMPL_FILE" "$PROXY_FILE"
    exit 1
fi

# Extract implementation address
IMPL_ADDRESS=$(echo "$IMPL_DEPLOY_OUTPUT" | grep "Deployed to:" | awk '{print $3}')

if [ -z "$IMPL_ADDRESS" ]; then
    echo ""
    echo "💥 FAILED TO EXTRACT IMPLEMENTATION ADDRESS!"
    echo "Cleaning up..."
    rm -f "$IMPL_FILE" "$PROXY_FILE"
    exit 1
fi

echo ""
echo "✅ IMPLEMENTATION DEPLOYMENT SUCCESSFUL!"
echo "📍 Implementation Address: $IMPL_ADDRESS"

# Step 5: Deploy the proxy contract
echo ""
echo "📦 [5/6] DEPLOYING PROXY CONTRACT..."
echo "=========================================="

# Use individual constructor args directly
echo "📋 Constructor args: $IMPL_ADDRESS $DEPLOYER_ADDRESS"

PROXY_DEPLOY_CMD="forge create $PROXY_SOURCE_FILE --private-key $PRIVATE_KEY --broadcast --constructor-args $IMPL_ADDRESS $DEPLOYER_ADDRESS"
echo "Running: forge create $PROXY_SOURCE_FILE --private-key [HIDDEN] --broadcast --constructor-args $IMPL_ADDRESS $DEPLOYER_ADDRESS"
echo ""

PROXY_DEPLOY_OUTPUT=$(eval "$PROXY_DEPLOY_CMD" 2>&1)
PROXY_DEPLOY_EXIT_CODE=$?

echo "$PROXY_DEPLOY_OUTPUT"

if [ $PROXY_DEPLOY_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "💥 PROXY DEPLOYMENT FAILED!"
    echo "Cleaning up..."
    rm -f "$IMPL_FILE" "$PROXY_FILE"
    exit 1
fi

# Extract proxy address
PROXY_ADDRESS=$(echo "$PROXY_DEPLOY_OUTPUT" | grep "Deployed to:" | awk '{print $3}')

if [ -z "$PROXY_ADDRESS" ]; then
    echo ""
    echo "💥 FAILED TO EXTRACT PROXY ADDRESS!"
    echo "Cleaning up..."
    rm -f "$IMPL_FILE" "$PROXY_FILE"
    exit 1
fi

echo ""
echo "✅ PROXY DEPLOYMENT SUCCESSFUL!"
echo "📍 Proxy Address: $PROXY_ADDRESS"

# Step 6: Verify both contracts
echo ""
echo "🔍 [6/6] VERIFYING CONTRACTS..."
echo "=========================================="

# Wait for transactions to be indexed
echo "⏳ Waiting 3 seconds for transactions to be indexed..."
sleep 3

# Track verification results
IMPL_ETHERSCAN_SUCCESS=false
IMPL_SOURCIFY_SUCCESS=false
IMPL_SOCIALSCAN_SUCCESS=false
PROXY_ETHERSCAN_SUCCESS=false
PROXY_SOURCIFY_SUCCESS=false
PROXY_SOCIALSCAN_SUCCESS=false

echo ""
echo "🔍 VERIFYING IMPLEMENTATION CONTRACT ($IMPL_ADDRESS)..."
echo "=============================================================="

# Implementation - Etherscan
echo ""
echo "🔍 [1/6] Implementation on Etherscan..."
if forge verify-contract --watch --chain 10143 "$IMPL_ADDRESS" "$IMPL_CONTRACT_NAME" --verifier etherscan --etherscan-api-key "$ETHERSCAN_API_KEY"; then
    IMPL_ETHERSCAN_SUCCESS=true
fi

# Implementation - Sourcify
echo ""
echo "🔍 [2/6] Implementation on Monad Explorer (Sourcify)..."
if forge verify-contract \
    "$IMPL_ADDRESS" \
    "$IMPL_CONTRACT_NAME" \
    --chain 10143 \
    --verifier sourcify \
    --verifier-url https://sourcify-api-monad.blockvision.org; then
    IMPL_SOURCIFY_SUCCESS=true
fi

# Implementation - Socialscan
echo ""
echo "🔍 [3/6] Implementation on Socialscan..."
if forge verify-contract \
    "$IMPL_ADDRESS" \
    "$IMPL_CONTRACT_NAME" \
    --chain 10143 \
    --watch \
    --etherscan-api-key test \
    --verifier-url https://api.socialscan.io/monad-testnet/v1/explorer/command_api/contract \
    --verifier etherscan; then
    IMPL_SOCIALSCAN_SUCCESS=true
fi

echo ""
echo "🔍 VERIFYING PROXY CONTRACT ($PROXY_ADDRESS)..."
echo "====================================================="

# Proxy - Etherscan
echo ""
echo "🔍 [4/6] Proxy on Etherscan..."
# Encode constructor args for verification
CONSTRUCTOR_ARGS_ENCODED=$(cast abi-encode "constructor(address,address)" "$IMPL_ADDRESS" "$DEPLOYER_ADDRESS")
if forge verify-contract --watch --chain 10143 "$PROXY_ADDRESS" "$PROXY_CONTRACT_NAME" --constructor-args "$CONSTRUCTOR_ARGS_ENCODED" --verifier etherscan --etherscan-api-key "$ETHERSCAN_API_KEY"; then
    PROXY_ETHERSCAN_SUCCESS=true
fi

# Proxy - Sourcify
echo ""
echo "🔍 [5/6] Proxy on Monad Explorer (Sourcify)..."
if forge verify-contract \
    "$PROXY_ADDRESS" \
    "$PROXY_CONTRACT_NAME" \
    --chain 10143 \
    --verifier sourcify \
    --verifier-url https://sourcify-api-monad.blockvision.org; then
    PROXY_SOURCIFY_SUCCESS=true
fi

# Proxy - Socialscan
echo ""
echo "🔍 [6/6] Proxy on Socialscan..."
if forge verify-contract \
    "$PROXY_ADDRESS" \
    "$PROXY_CONTRACT_NAME" \
    --chain 10143 \
    --watch \
    --etherscan-api-key test \
    --verifier-url https://api.socialscan.io/monad-testnet/v1/explorer/command_api/contract \
    --verifier etherscan; then
    PROXY_SOCIALSCAN_SUCCESS=true
fi

# Final Summary
echo ""
echo "=========================================="
echo "📊 SIMPLE PROXY VERIFICATION SUMMARY"
echo "=========================================="
echo "🧪 Implementation Contract: $IMPL_CONTRACT_NAME"
echo "📍 Implementation Address: $IMPL_ADDRESS"
echo "🧪 Proxy Contract: $PROXY_CONTRACT_NAME"
echo "📍 Proxy Address: $PROXY_ADDRESS"
echo "🔧 Implementation Random Functions: $IMPL_FUNC1_NAME, $IMPL_FUNC2_NAME, $IMPL_FUNC3_NAME"
echo "🔧 Proxy Random Functions: $PROXY_FUNC1_NAME, $PROXY_FUNC2_NAME, $PROXY_FUNC3_NAME"
echo ""
echo "🔗 BLOCK EXPLORER LINKS:"
echo "=========================================="
echo "📍 IMPLEMENTATION CONTRACT ($IMPL_ADDRESS):"
echo "   Monadscan:     https://testnet.monadscan.com/address/$IMPL_ADDRESS"
echo "   Socialscan:    https://monad-testnet.socialscan.io/address/$IMPL_ADDRESS"
echo "   Monad Explorer: https://testnet.monadexplorer.com/address/$IMPL_ADDRESS"
echo ""
echo "📍 PROXY CONTRACT ($PROXY_ADDRESS):"
echo "   Monadscan:     https://testnet.monadscan.com/address/$PROXY_ADDRESS"
echo "   Socialscan:    https://monad-testnet.socialscan.io/address/$PROXY_ADDRESS"
echo "   Monad Explorer: https://testnet.monadexplorer.com/address/$PROXY_ADDRESS"
echo ""
echo "🔍 Check these URLs to verify proxy detection on each explorer!"
echo ""

echo "IMPLEMENTATION CONTRACT RESULTS:"
if [ "$IMPL_ETHERSCAN_SUCCESS" = true ]; then
    echo "✅ Etherscan: SUCCESS"
else
    echo "❌ Etherscan: FAILED"
fi

if [ "$IMPL_SOURCIFY_SUCCESS" = true ]; then
    echo "✅ Monad Explorer (Sourcify): SUCCESS"
else
    echo "❌ Monad Explorer (Sourcify): FAILED"
fi

if [ "$IMPL_SOCIALSCAN_SUCCESS" = true ]; then
    echo "✅ Socialscan: SUCCESS"
else
    echo "❌ Socialscan: FAILED"
fi

echo ""
echo "PROXY CONTRACT RESULTS:"
if [ "$PROXY_ETHERSCAN_SUCCESS" = true ]; then
    echo "✅ Etherscan: SUCCESS"
else
    echo "❌ Etherscan: FAILED"
fi

if [ "$PROXY_SOURCIFY_SUCCESS" = true ]; then
    echo "✅ Monad Explorer (Sourcify): SUCCESS"
else
    echo "❌ Monad Explorer (Sourcify): FAILED"
fi

if [ "$PROXY_SOCIALSCAN_SUCCESS" = true ]; then
    echo "✅ Socialscan: SUCCESS"
else
    echo "❌ Socialscan: FAILED"
fi

echo "=========================================="

# Calculate overall success
TOTAL_SUCCESS=0
TOTAL_ATTEMPTED=6

if [ "$IMPL_ETHERSCAN_SUCCESS" = true ]; then TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1)); fi
if [ "$IMPL_SOURCIFY_SUCCESS" = true ]; then TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1)); fi
if [ "$IMPL_SOCIALSCAN_SUCCESS" = true ]; then TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1)); fi
if [ "$PROXY_ETHERSCAN_SUCCESS" = true ]; then TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1)); fi
if [ "$PROXY_SOURCIFY_SUCCESS" = true ]; then TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1)); fi
if [ "$PROXY_SOCIALSCAN_SUCCESS" = true ]; then TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1)); fi

echo "🎯 Test Result: $TOTAL_SUCCESS/$TOTAL_ATTEMPTED verifications successful"

# Cleanup
echo ""
echo "🧹 CLEANING UP..."
echo "Removing test files: $IMPL_FILE $PROXY_FILE"
rm -f "$IMPL_FILE" "$PROXY_FILE"

if [ $TOTAL_SUCCESS -eq $TOTAL_ATTEMPTED ]; then
    echo "🎉 All simple proxy verification tests passed!"
    exit 0
elif [ $TOTAL_SUCCESS -gt 0 ]; then
    echo "⚠️  Partial success - some verifications failed"
    exit 0
else
    echo "💥 All simple proxy verification tests failed"
    exit 1
fi 