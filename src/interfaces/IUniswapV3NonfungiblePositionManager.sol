// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IUniswapV3NonfungiblePositionManager {
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    /// @notice Returns the WETH9 address used in the contract
    function WETH9() external view returns (address);

    /// @notice Returns the Uniswap V3 factory address
    function factory() external view returns (address);

    /// @notice Creates a Uniswap V3 pool and initializes it if necessary
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);

    /// @notice Mints a new liquidity position NFT
    function mint(
        MintParams calldata params
    )
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    /// @notice Increases liquidity for an existing position
    function increaseLiquidity(
        IncreaseLiquidityParams calldata params
    )
        external
        payable
        returns (uint128 liquidity, uint256 amount0, uint256 amount1);

    /// @notice Decreases liquidity and burns position if liquidity is fully removed
    function decreaseLiquidity(
        DecreaseLiquidityParams calldata params
    ) external payable returns (uint256 amount0, uint256 amount1);

    /// @notice Collects earned fees from a position
    function collect(
        CollectParams calldata params
    ) external payable returns (uint256 amount0, uint256 amount1);

    /// @notice Burns a position NFT after removing all liquidity
    function burn(uint256 tokenId) external payable;

    /// @notice Gets the number of NFTs owned by an address
    function balanceOf(address owner) external view returns (uint256);

    /// @notice Gets the NFT ID at a given index for a wallet
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view returns (uint256);

    /// @notice Fetches details of a specific position NFT
    function positions(
        uint256 tokenId
    )
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice Transfers NFT ownership
    function transferFrom(address from, address to, uint256 tokenId) external;

    /// @notice Safe transfers NFT ownership with data
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /// @notice Approves another address to manage an NFT
    function approve(address to, uint256 tokenId) external;

    /// @notice Sets approval for all NFTs owned by a user
    function setApprovalForAll(address operator, bool approved) external;

    /// @notice Checks if an address is approved for an NFT
    function getApproved(uint256 tokenId) external view returns (address);

    /// @notice Checks if an operator is approved for all NFTs owned by a user
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}
