# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Monad-flavored Foundry template repository for Ethereum smart contract development. It's configured specifically for the Monad Testnet blockchain (chain ID 10143) and includes comprehensive verification testing scripts for multiple block explorers.

## Key Commands

### Build and Compilation
```bash
forge build                    # Build all contracts
forge build --skip test       # Build contracts, skip test files
```

### Testing
```bash
forge test                     # Run all tests
```

### Code Formatting
```bash
forge fmt                      # Format Solidity code
```

### Gas Analysis
```bash
forge snapshot                 # Generate gas usage snapshots
```

### Local Development
```bash
anvil                          # Start local Ethereum node
```

### Deployment (Monad Testnet)

1. Create keystore (one-time setup):
```bash
cast wallet import monad-deployer --private-key $(cast wallet new | grep 'Private key:' | awk '{print $3}')
```

2. Check deployer address:
```bash
cast wallet address --account monad-deployer
```

3. Deploy contracts:
```bash
forge create src/Counter.sol:Counter --account monad-deployer --broadcast
```

4. Deploy with constructor arguments:
```bash
forge create src/Counter.sol:Counter --account monad-deployer --broadcast --constructor-args <constructor_arguments>
```

### Contract Verification

#### Standard verification (multiple explorers):
```bash
# Etherscan
forge verify-contract --watch --chain 10143 <contract_address> src/Counter.sol:Counter --verifier etherscan --etherscan-api-key <api_key>

# Monad Explorer (Sourcify)
forge verify-contract <contract_address> src/Counter.sol:Counter --chain 10143 --verifier sourcify --verifier-url https://sourcify-api-monad.blockvision.org

# Socialscan
forge verify-contract <contract_address> src/Counter.sol:Counter --chain 10143 --watch --etherscan-api-key test --verifier-url https://api.socialscan.io/monad-testnet/v1/explorer/command_api/contract --verifier blockscout
```

#### With constructor arguments:
```bash
forge verify-contract <contract_address> src/Counter.sol:Counter --chain 10143 --verifier sourcify --verifier-url https://sourcify-api-monad.blockvision.org --constructor-args <abi_encoded_constructor_arguments>
```

### Verification Testing Scripts

The repository includes two comprehensive testing scripts for automated verification testing:

#### Basic Contract Verification Test:
```bash
bash script/testVerification.sh [contract_source_file]
```
- Creates random contract variants with unique functions
- Deploys and verifies on all three block explorers
- Default: tests `src/Counter.sol:Counter`

#### Proxy Contract Verification Test:
```bash
bash script/testSimpleProxyVerification.sh
```
- Creates and deploys both implementation and proxy contracts
- Tests verification of proxy patterns across all explorers
- Provides block explorer links for manual verification

## Network Configuration

- **Chain ID**: 10143 (Monad Testnet)
- **RPC URL**: https://testnet-rpc.monad.xyz
- **Block Explorers**:
  - Monadscan: https://testnet.monadscan.com
  - Socialscan: https://monad-testnet.socialscan.io
  - Monad Explorer: https://testnet.monadexplorer.com

## Architecture and Structure

### Core Contracts

- **Counter.sol**: Basic counter contract with increment/set functionality
- **SimpleImplementation.sol**: Implementation contract for proxy pattern with ownership and initialization
- **SimpleProxy.sol**: Custom proxy contract using EIP-1967 storage slots for upgradeable patterns

### Script Organization

- **script/Counter.s.sol**: Basic deployment script template
- **script/testVerification.sh**: Comprehensive verification testing for single contracts
- **script/testSimpleProxyVerification.sh**: Verification testing for proxy patterns

### Dependencies

- **forge-std**: Standard Foundry testing and scripting utilities
- **openzeppelin-contracts**: OpenZeppelin contract library for security patterns

### Configuration

- **foundry.toml**: Configured for Monad Testnet with metadata settings optimized for verification
- Metadata hash disabled (`metadata_hash = "none"`) to avoid IPFS dependencies
- Literal content enabled (`use_literal_content = true`) for source code verification

## Development Workflow

1. Use the verification testing scripts frequently to ensure contract verification works across all block explorers
2. The repository is specifically configured for Monad Testnet - change network settings in `foundry.toml` if targeting other chains
3. Both basic contracts and proxy patterns are supported with dedicated testing infrastructure
4. Keystore management is used instead of raw private keys for security

## Troubleshooting

- **Insufficient balance error**: Check deployer balance with `cast wallet address --account monad-deployer`
- **Verification failures**: Use the testing scripts to diagnose issues across different block explorers
- **Constructor argument issues**: Use `cast abi-encode` to properly encode constructor arguments for verification

The verification testing scripts provide detailed output and cleanup temporary files automatically, making them safe for repeated use during development.