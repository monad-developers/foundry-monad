## Monad flavored Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Format

```shell
forge fmt
```

### Gas Snapshots

```shell
forge snapshot
```

### Anvil

```shell
anvil
```

### Deploy to Monad Testnet

First, you need to create a keystore file. Do not forget to remember the password! You will need it to deploy your contract.

```shell
cast wallet import monad-deployer --private-key $(cast wallet new | grep 'Private key:' | awk '{print $3}')
```

After creating the keystore, you can read its address using:

```shell
cast wallet address --account monad-deployer
```

The command above will create a keystore file named `monad-deployer` in the ~/.foundry/keystores directory.

Then, you can deploy your contract to the Monad Testnet using the keystore file you created.

```shell
forge create src/Counter.sol:Counter --account monad-deployer --broadcast
```

## Verify Your Contract on Monad Testnet

```shell
forge verify-contract <contract_address> <contract_name> --chain-id 10143 --verifier sourcify --verifier-url https://sourcify-api-monad.blockvision.org 
```

### Cast

```shell
cast <subcommand>
```

### Help

```shell
forge --help
anvil --help
cast --help
```


## FAQ

### Error: `Error: server returned an error response: error code -32603: Signer had insufficient balance`

This error happens when you don't have enough balance to deploy your contract. You can check your balance with the following command:

```shell
cast wallet address --account monad-deployer
```

### I have constructor arguments, how do I deploy my contract?

```shell
forge create src/Counter.sol:Counter --account monad-deployer --broadcast --constructor-args <constructor_arguments>
```

### I have constructor arguments, how do I verify my contract?

```shell
forge verify-contract <contract_address> <contract_name> --chain-id 10143 --verifier sourcify --verifier-url https://sourcify-api-monad.blockvision.org --constructor-args <abi_encoded_constructor_arguments>
```

Please refer to the [Foundry Book](https://book.getfoundry.sh/) for more information.