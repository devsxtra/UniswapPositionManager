// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {console} from "forge-std/Test.sol";
import {IUniswapV3NonfungiblePositionManager} from "../src/interfaces/IUniswapV3NonfungiblePositionManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract UniswapV3LiquidityManager {
    using SafeERC20 for IERC20;

    /// @notice Uniswap V3 Nonfungible Position Manager contract
    IUniswapV3NonfungiblePositionManager public immutable positionManager;

    /// @notice Token ID of the Uniswap V3 position
    mapping(address => uint256[] positions) public userPositionIds;

    /// @notice Uniswap pool parameters
    address public constant USDC = 0x284c540835AF646Bc9fca74Fd384517456E7f2d4;
    address public constant WETH = 0xF42C5983DeED3D4b0e988aE2d5ff4cCDcbB4b04f;

    /// @notice Event emitted when liquidity is minted
    event Minted(uint256 tokenId, uint128 liquidity);

    /// @notice Event emitted when liquidity is burned
    event Burned(uint256 tokenId, uint256 amount0, uint256 amount1);

    /// @notice Event emitted when liquidity is rebalanced
    event Rebalanced(uint256 newTokenId, uint128 newLiquidity);

    constructor(address _positionManager) {
        positionManager = IUniswapV3NonfungiblePositionManager(
            _positionManager
        );
    }

    function mintLiquidity(
        uint256 amount0Desired,
        uint256 amount1Desired,
        int24 lowerTick,
        int24 upperTick,
        uint24 feeTier
    ) public returns (uint256 tokenId, uint128 liquidity) {
        IERC20(USDC).safeTransferFrom(
            msg.sender,
            address(this),
            amount0Desired
        );
        IERC20(WETH).safeTransferFrom(
            msg.sender,
            address(this),
            amount1Desired
        );

        IERC20(USDC).forceApprove(address(positionManager), amount0Desired);
        IERC20(WETH).forceApprove(address(positionManager), amount1Desired);

        IUniswapV3NonfungiblePositionManager.MintParams
            memory params = IUniswapV3NonfungiblePositionManager.MintParams({
                token0: USDC,
                token1: WETH,
                fee: feeTier,
                tickLower: lowerTick,
                tickUpper: upperTick,
                amount0Desired: amount0Desired,
                amount1Desired: amount1Desired,
                amount0Min: (amount0Desired * 96) / 100,
                amount1Min: (amount1Desired * 96) / 100,
                recipient: msg.sender,
                deadline: block.timestamp
            });

        (tokenId, liquidity, , ) = positionManager.mint(params);

        userPositionIds[msg.sender].push(tokenId);
        emit Minted(tokenId, liquidity);
    }

    /**
     * @notice Burns liquidity and collects tokens from Uniswap V3 position
     * @param tokenId The token ID of the position
     * @param liquidity Amount of liquidity to remove
     */
    function burnLiquidity(uint256 tokenId, uint128 liquidity) external {
        require(userPositionIds[msg.sender].length > 0, "no postion exists");

        IUniswapV3NonfungiblePositionManager.DecreaseLiquidityParams
            memory params = IUniswapV3NonfungiblePositionManager
                .DecreaseLiquidityParams({
                    tokenId: tokenId,
                    liquidity: liquidity,
                    amount0Min: 0,
                    amount1Min: 0,
                    deadline: block.timestamp
                });

        positionManager.transferFrom(msg.sender, address(this), tokenId);
        positionManager.approve(address(positionManager), tokenId);
        positionManager.decreaseLiquidity(params);

        _removePosition(msg.sender, tokenId);

        IUniswapV3NonfungiblePositionManager.CollectParams
            memory collectParams = IUniswapV3NonfungiblePositionManager
                .CollectParams({
                    tokenId: tokenId,
                    recipient: msg.sender,
                    amount0Max: type(uint128).max,
                    amount1Max: type(uint128).max
                });

        (uint256 amount0, uint256 amount1) = positionManager.collect(
            collectParams
        );

        emit Burned(tokenId, amount0, amount1);
    }

    /**
     * @notice Rebalances liquidity by withdrawing and re-minting at new range
     * @param lowerTick New lower tick
     * @param upperTick New upper tick
     */
    function rebalanceLiquidity(
        uint256 tokenId,
        uint128 liquidity,
        int24 lowerTick,
        int24 upperTick
    ) external {
        require(userPositionIds[msg.sender].length > 0, "No active position");

        positionManager.transferFrom(msg.sender, address(this), tokenId);
        positionManager.approve(address(positionManager), tokenId);

        // Burn existing liquidity
        IUniswapV3NonfungiblePositionManager.DecreaseLiquidityParams
            memory decreaseParams = IUniswapV3NonfungiblePositionManager
                .DecreaseLiquidityParams({
                    tokenId: tokenId,
                    liquidity: liquidity, // Remove all liquidity
                    amount0Min: 0,
                    amount1Min: 0,
                    deadline: block.timestamp
                });

        positionManager.decreaseLiquidity(decreaseParams);

        IUniswapV3NonfungiblePositionManager.CollectParams
            memory collectParams = IUniswapV3NonfungiblePositionManager
                .CollectParams({
                    tokenId: tokenId,
                    recipient: address(this),
                    amount0Max: type(uint128).max,
                    amount1Max: type(uint128).max
                });

        (uint256 amount0, uint256 amount1) = positionManager.collect(
            collectParams
        );

        // Burn old NFT
        positionManager.burn(tokenId);
        _removePosition(msg.sender, tokenId);

        IERC20(USDC).forceApprove(address(positionManager), amount0);
        IERC20(WETH).forceApprove(address(positionManager), amount1);

        IUniswapV3NonfungiblePositionManager.MintParams
            memory params = IUniswapV3NonfungiblePositionManager.MintParams({
                token0: USDC,
                token1: WETH,
                fee: 10000,
                tickLower: lowerTick,
                tickUpper: upperTick,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: 0,
                amount1Min: 0,
                recipient: msg.sender,
                deadline: block.timestamp
            });

        (uint256 newTokenId, uint128 newLiquidity, , ) = positionManager.mint(
            params
        );

        userPositionIds[msg.sender].push(tokenId);
        emit Rebalanced(newTokenId, newLiquidity);
    }

    /**
     * @notice Withdraw ERC20 tokens from the contract
     * @param token Address of the token to withdraw
     * @param recipient Address to receive the tokens
     * @param amount Amount to withdraw
     */
    function withdrawERC20(
        address token,
        address recipient,
        uint256 amount
    ) external {
        IERC20(token).safeTransfer(recipient, amount);
    }

    /**
     * @notice Retrieves the list of position IDs for a given user address.
     * @param user The address of the user whose position IDs are being queried.
     * @return positionIds The array of position IDs associated with the user.
     */
    function getUserPositionIds(
        address user
    ) external view returns (uint256[] memory) {
        return userPositionIds[user];
    }

    /**
     * @notice Removes a position ID from the user's position list.
     * @dev Uses swap-and-pop to remove efficiently.
     * @param user The address of the user.
     * @param positionId The position ID to remove.
     */
    function _removePosition(address user, uint256 positionId) internal {
        uint256[] storage positions = userPositionIds[user];
        uint256 length = positions.length;
        require(length > 0, "No positions to remove");

        // Find the index of the positionId
        uint256 index = length; // Default to out-of-bounds
        for (uint256 i = 0; i < length; i++) {
            if (positions[i] == positionId) {
                index = i;
                break;
            }
        }

        require(index < length, "Position not found");

        // Swap with the last element and remove the last element
        positions[index] = positions[length - 1];
        positions.pop();
    }
}
