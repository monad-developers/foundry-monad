## Foundry-Monad

> [!NOTE]  
> In this Foundry template, the default chain is `monadDevnet`. If you wish to use a different network, modify the settings in `foundry.toml`
<!-- TODO: Add Image -->

<h4 align="center">
  <a href="https://docs.monad.xyz">Monad Documentation</a> | 
  <a href="https://book.getfoundry.sh/">Foundry Documentation</a> | 
  <a href="https://github.com/monad-developers/foundry-monad/issues">Report Issue</a>
</h4>

## 📝 Description

Foundry-Monad is a pre-configured Foundry template for the Monad network. This template enables developers to quickly start development without the need to perform initial Foundry setup for the Monad network.

### What is Foundry?

Foundry is a high-performance, portable, and modular toolkit for Ethereum application development written in Rust.

Core Components:

-   **Forge**: Ethereum smart contract testing framework
-   **Cast**: Swiss army knife for interacting with EVM smart contracts
-   **Anvil**: Local Ethereum node for development
-   **Chisel**: Fast and feature-rich Solidity REPL

## 🛠 Requirements

Before you begin, ensure you have the following installed:

-   [Rust](https://www.rust-lang.org/tools/install)
-   [Cargo](https://doc.rust-lang.org/cargo/getting-started/installation.html)
-   [Foundryup](https://book.getfoundry.sh/getting-started/installation)

## 🚀 Quick Start

### Option 1: Clone the Repository

```sh
git clone https://github.com/monad-developers/foundry-monad
cd foundry-monad
forge install
```

### Option 2: Create Project from Template

```sh
mkdir [project_name] && cd [project_name]
forge init --template monad-developers/foundry-monad
```

## 💻 Core Commands

### Compilation
```shell
forge compile
```

### Build
```shell
forge build
```

### Testing
```shell
forge test
```

### Deploy Contract
```shell
forge create --private-key <your_private_key> src/Counter.sol:Counter
```

### Verify Contract
```shell
forge verify-contract <contract_address> src/Counter.sol:Counter
```

### Format Code
```shell
forge fmt
```

### Gas Analysis
```shell
forge snapshot
```

### Run Local Node
```shell
anvil
```

## 🤝 How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to your fork (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📚 Additional Resources

- [Official Monad Website](https://monad.xyz)
- [Foundry Documentation](https://book.getfoundry.sh/)
- [Monad Community Chat](https://t.me/monad_xyz)

## 📄 License

Distributed under the MIT License. See `LICENSE` file for more information.
