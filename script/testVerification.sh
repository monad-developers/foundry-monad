#!/bin/bash

# Test verification script for Monad network
# This script creates a random variant of a contract, deploys it, and verifies it
# Usage: bash testVerification.sh

# Hardcoded values
PRIVATE_KEY="${PRIVATE_KEY:-}"
ETHERSCAN_API_KEY="REDACTED_API_KEY"

# Default values
DEFAULT_SOURCE_FILE="src/Counter.sol:Counter"

# Parse arguments with defaults
SOURCE_FILE="${1:-$DEFAULT_SOURCE_FILE}"

# Extract contract name and file path
CONTRACT_NAME=$(echo "$SOURCE_FILE" | cut -d':' -f2)
ORIGINAL_FILE=$(echo "$SOURCE_FILE" | cut -d':' -f1)

# Generate random suffix for test contract (macOS compatible)
RANDOM_SUFFIX=$(date +%s)$(jot -r 1 1000 9999)
TEST_CONTRACT_NAME="${CONTRACT_NAME}Test${RANDOM_SUFFIX}"
TEST_FILE="src/${TEST_CONTRACT_NAME}.sol"
TEST_SOURCE_FILE="${TEST_FILE}:${TEST_CONTRACT_NAME}"



echo "=========================================="
echo "🧪 VERIFICATION TEST WORKFLOW"
echo "=========================================="
echo "Original: $ORIGINAL_FILE"
echo "Test Contract: $TEST_CONTRACT_NAME"
echo "Test File: $TEST_FILE"
echo "Using hardcoded private key"
echo "=========================================="

# Step 1: Create a modified version of the contract
echo ""
echo "🔧 [1/4] CREATING RANDOM CONTRACT VARIANT..."
echo "=========================================="

if [ ! -f "$ORIGINAL_FILE" ]; then
    echo "💥 ERROR: Original file $ORIGINAL_FILE not found!"
    exit 1
fi

# Generate random function names (macOS compatible)
FUNC1_NAME="randomFunction$(jot -r 1 100 999)"
FUNC2_NAME="testFunction$(jot -r 1 100 999)"
FUNC3_NAME="dummyFunction$(jot -r 1 100 999)"

# Generate random values (macOS compatible)
RANDOM_VALUE1=$(jot -r 1 1 1000)
RANDOM_VALUE2=$(jot -r 1 1001 2000)
RANDOM_VALUE3=$(jot -r 1 2001 3000)

# Read the original contract and replace contract name
ORIGINAL_CONTENT=$(cat "$ORIGINAL_FILE")

# Replace contract name
MODIFIED_CONTENT=$(echo "$ORIGINAL_CONTENT" | sed "s/contract ${CONTRACT_NAME}/contract ${TEST_CONTRACT_NAME}/g")

# Create a temporary file and write the modified content without the last closing brace
echo "$MODIFIED_CONTENT" | sed '$d' > "$TEST_FILE"

# Add the random functions and the closing brace
cat >> "$TEST_FILE" << EOF

    // Random test functions to make this contract unique
    function ${FUNC1_NAME}() public pure returns (uint256) {
        return ${RANDOM_VALUE1};
    }

    function ${FUNC2_NAME}(uint256 _input) public pure returns (uint256) {
        return _input + ${RANDOM_VALUE2};
    }

    function ${FUNC3_NAME}() public view returns (string memory) {
        return "Test function ${RANDOM_VALUE3}";
    }
}
EOF

echo "✅ Created test contract: $TEST_CONTRACT_NAME"
echo "📄 Added random functions: $FUNC1_NAME, $FUNC2_NAME, $FUNC3_NAME"

# Show a preview of the generated contract
echo ""
echo "📄 Contract preview (last 15 lines):"
tail -15 "$TEST_FILE"

# Step 2: Compile the test contract (exclude tests to avoid conflicts)
echo ""
echo "🔨 [2/4] COMPILING TEST CONTRACT..."
echo "=========================================="

if ! forge build --skip test; then
    echo "💥 COMPILATION FAILED!"
    echo "Cleaning up..."
    rm -f "$TEST_FILE"
    exit 1
fi

echo "✅ Compilation successful!"

# Step 3: Deploy the test contract
echo ""
echo "📦 [3/4] DEPLOYING TEST CONTRACT..."
echo "=========================================="

DEPLOY_CMD="forge create $TEST_SOURCE_FILE --private-key $PRIVATE_KEY --broadcast"
echo "Running: forge create $TEST_SOURCE_FILE --private-key [HIDDEN] --broadcast"
echo ""

# Capture the deploy output
DEPLOY_OUTPUT=$(eval "$DEPLOY_CMD" 2>&1)
DEPLOY_EXIT_CODE=$?

echo "$DEPLOY_OUTPUT"

if [ $DEPLOY_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "💥 DEPLOYMENT FAILED!"
    echo "Exit code: $DEPLOY_EXIT_CODE"
    echo "Cleaning up..."
    rm -f "$TEST_FILE"
    exit 1
fi

# Extract the deployed contract address from the output
CONTRACT_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep "Deployed to:" | awk '{print $3}')

if [ -z "$CONTRACT_ADDRESS" ]; then
    echo ""
    echo "💥 FAILED TO EXTRACT CONTRACT ADDRESS!"
    echo "Could not find 'Deployed to:' in the output"
    echo "Cleaning up..."
    rm -f "$TEST_FILE"
    exit 1
fi

echo ""
echo "✅ DEPLOYMENT SUCCESSFUL!"
echo "📍 Contract Address: $CONTRACT_ADDRESS"

# Step 4: Verify the test contract
echo ""
echo "🔍 [4/4] VERIFYING TEST CONTRACT..."
echo "=========================================="

# Wait a moment for the transaction to be mined and indexed
echo "⏳ Waiting 3 seconds for transaction to be indexed..."
sleep 3

# Track verification results
ETHERSCAN_SUCCESS=false
SOURCIFY_SUCCESS=false
SOCIALSCAN_SUCCESS=false

# 1. Etherscan Verification (only if API key is available)
if [ -n "$ETHERSCAN_API_KEY" ]; then
    echo ""
    echo "🔍 [1/3] Verifying on Etherscan..."
    if forge verify-contract --watch --chain 10143 "$CONTRACT_ADDRESS" "$TEST_CONTRACT_NAME" --verifier etherscan --etherscan-api-key "$ETHERSCAN_API_KEY"; then
        ETHERSCAN_SUCCESS=true
    fi
else
    echo ""
    echo "⏭️  [1/3] Skipping Etherscan (no API key)"
fi

# 2. Monad Explorer (Sourcify) Verification
echo ""
echo "🔍 [2/3] Verifying on Monad Explorer (Sourcify)..."
if forge verify-contract \
    "$CONTRACT_ADDRESS" \
    "$TEST_CONTRACT_NAME" \
    --chain 10143 \
    --verifier sourcify \
    --verifier-url https://sourcify-api-monad.blockvision.org; then
    SOURCIFY_SUCCESS=true
fi

# 3. Socialscan Verification
echo ""
echo "🔍 [3/3] Verifying on Socialscan..."
if forge verify-contract \
    "$CONTRACT_ADDRESS" \
    "$TEST_CONTRACT_NAME" \
    --chain 10143 \
    --watch \
    --etherscan-api-key test \
    --verifier-url https://api.socialscan.io/monad-testnet/v1/explorer/command_api/contract \
    --verifier blockscout; then
    SOCIALSCAN_SUCCESS=true
fi

# Final Summary
echo ""
echo "=========================================="
echo "📊 VERIFICATION TEST SUMMARY"
echo "=========================================="
echo "🧪 Test Contract: $TEST_CONTRACT_NAME"
echo "📍 Contract Address: $CONTRACT_ADDRESS"
echo "🔧 Random Functions: $FUNC1_NAME, $FUNC2_NAME, $FUNC3_NAME"
echo ""

if [ -n "$ETHERSCAN_API_KEY" ]; then
    if [ "$ETHERSCAN_SUCCESS" = true ]; then
        echo "✅ Etherscan: SUCCESS"
    else
        echo "❌ Etherscan: FAILED"
    fi
else
    echo "⏭️  Etherscan: SKIPPED (no API key)"
fi

if [ "$SOURCIFY_SUCCESS" = true ]; then
    echo "✅ Monad Explorer (Sourcify): SUCCESS"
else
    echo "❌ Monad Explorer (Sourcify): FAILED"
fi

if [ "$SOCIALSCAN_SUCCESS" = true ]; then
    echo "✅ Socialscan: SUCCESS"
else
    echo "❌ Socialscan: FAILED"
fi

echo "=========================================="

# Calculate overall success
TOTAL_SUCCESS=0
TOTAL_ATTEMPTED=0

if [ -n "$ETHERSCAN_API_KEY" ]; then
    TOTAL_ATTEMPTED=$((TOTAL_ATTEMPTED + 1))
    if [ "$ETHERSCAN_SUCCESS" = true ]; then
        TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
    fi
fi

TOTAL_ATTEMPTED=$((TOTAL_ATTEMPTED + 1))
if [ "$SOURCIFY_SUCCESS" = true ]; then
    TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
fi

TOTAL_ATTEMPTED=$((TOTAL_ATTEMPTED + 1))
if [ "$SOCIALSCAN_SUCCESS" = true ]; then
    TOTAL_SUCCESS=$((TOTAL_SUCCESS + 1))
fi

echo "🎯 Test Result: $TOTAL_SUCCESS/$TOTAL_ATTEMPTED verifications successful"

# Cleanup
echo ""
echo "🧹 CLEANING UP..."
echo "Removing test file: $TEST_FILE"
rm -f "$TEST_FILE"

if [ $TOTAL_SUCCESS -eq $TOTAL_ATTEMPTED ]; then
    echo "🎉 All verification tests passed!"
    exit 0
elif [ $TOTAL_SUCCESS -gt 0 ]; then
    echo "⚠️  Partial success - some verifications failed"
    exit 0
else
    echo "💥 All verification tests failed"
    exit 1
fi 