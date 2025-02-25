## Foundry-Monad

> [!NOTE]  
> In this foundry template, the default chain is `monadDevnet`. If you wish to change it, modify the network in `foundry.toml`.

<!-- TODO: Add Image -->

<h4 align="center">
  <a href="https://docs.monad.xyz">Monad Documentation</a> | <a href="https://book.getfoundry.sh/">Foundry Documentation</a> | 
  <a href="https://github.com/monad-developers/foundry-monad/issues">Report Issue</a>
</h4>

_Foundry-Monad is a Foundry template with Monad configuration, so developers don't have to do the initial configuration in Foundry for the Monad network._

**Foundry is a blazing fast, portable, and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat, and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions, and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose Solidity REPL.

## Requirements

Before you begin, you need to install the following tools:

-   Rust
-   Cargo
-   [Foundryup](https://book.getfoundry.sh/getting-started/installation)

## Quickstart

To get started, follow the steps below:

1. You can clone this repo using the following command:

```sh
git clone https://github.com/monad-developers/foundry-monad
```

Or you can do it manually using the following set of commands:

```sh
mkdir [project_name] && cd [project_name] && forge init --template monad-developers/foundry-monad
```

The Foundry project is now ready to be used!

## Examples

### Compile

```shell
forge compile
```

### Build

```shell
forge build
```

### Test

```shell
forge test
```

### Deploy

```shell
forge create --private-key <your_private_key> src/Counter.sol:Counter
```

### Verify Contract

```shell
forge verify-contract <contract_address> src/Counter.sol:Counter
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

### Cast

```shell
cast <subcommand>
```

### Help

```shell
forge --help
```

```shell
anvil --help
```

```shell
cast --help
```