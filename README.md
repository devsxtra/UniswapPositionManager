## Uniswap Position Manager

📌 Overview
The UniswapV3LiquidityManager contract allows users to mint, burn, and rebalance Uniswap V3 liquidity positions using the Uniswap V3 Position Manager. This contract simplifies liquidity provision by automating interactions with Uniswap V3.

📜 Features

- ✅ Mint Liquidity: Deposit USDC and WETH to create a Uniswap V3 position and mint the NFT
- ✅ Burn Liquidity: Withdraw deposited tokens by removing liquidity from a position
- ✅ Rebalance Position: Adjust price range by withdrawing liquidity and re-minting at new ticks
- ✅ Track User Positions: Retrieve all Uniswap V3 position token IDs owned by a user
- ✅ Withdraw ERC-20 Tokens: Allow withdrawal of accidentally sent ERC-20 tokens

⚙️ Contract Functions

1️⃣ Mint Liquidity
````
  function mintLiquidity(
      uint256 amount0Desired,
      uint256 amount1Desired,
      int24 lowerTick,
      int24 upperTick,
      uint24 feeTier
  ) public returns (uint256 tokenId, uint128 liquidity);
````
- ✅ Transfers USDC and WETH from the user
- ✅ Approves the Uniswap V3 Nonfungible Position Manager
- ✅ Calls mint() to create a Uniswap V3 position
- ✅ Returns position token ID and liquidity amount

2️⃣ Burn Liquidity
````
function burnLiquidity(uint256 tokenId, uint128 liquidity) external;
````
- ✅ Removes liquidity from a Uniswap V3 position
- ✅ Calls decreaseLiquidity() on the position manager
- ✅ Collects tokens from Uniswap after burning liquidity
- ✅ Updates user positions by removing the token ID

3️⃣ Rebalance Liquidity
````
function rebalanceLiquidity(
    uint256 tokenId,
    uint128 liquidity,
    int24 lowerTick,
    int24 upperTick
) external;
````
- ✅ Withdraws existing liquidity
- ✅ Collects tokens from Uniswap after burning liquidity
- ✅ Mints new liquidity in a different price range
- ✅ Burns old NFT and issues a new one




## Foundry

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
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
