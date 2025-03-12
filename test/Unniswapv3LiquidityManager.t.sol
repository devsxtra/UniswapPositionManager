// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/UniswapPositionManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IUniswapV3NonfungiblePositionManager} from "../src/interfaces/IUniswapV3NonfungiblePositionManager.sol";

contract UniswapV3LiquidityManagerTest is Test {
    UniswapV3LiquidityManager liquidityManager;

    address constant WETH = 0xF42C5983DeED3D4b0e988aE2d5ff4cCDcbB4b04f;
    address constant USDC = 0x284c540835AF646Bc9fca74Fd384517456E7f2d4;
    address constant POOL = 0xEEC3c35F26b8F45998f25AF9E867f35b779b2757;
    address constant POSITION_MANAGER =
        0x3dCc735C74F10FE2B9db2BB55C40fbBbf24490f7; // Uniswap V3 Position Manager

    address owner;

    function setUp() public {
        vm.createSelectFork(vm.envString("MONAD_RPC_URL"));
        owner = address(this);
        liquidityManager = new UniswapV3LiquidityManager(POSITION_MANAGER);
    }

    function testMintLiquidityWithPoolCreation() public {
        uint256 amount1 = 1 ether; // 1 WETH
        uint256 amount0 = 2100 * 10 ** 18; // 2100 USDC (1 WETH = 2100 USDC)

        deal(WETH, owner, amount1);
        deal(USDC, owner, amount0);

        IERC20(WETH).approve(address(liquidityManager), amount1);
        IERC20(USDC).approve(address(liquidityManager), amount0);

        // Mint liquidity
        (uint256 tokenId, uint128 liquidity) = liquidityManager.mintLiquidity(
            amount0,
            amount1,
            -887200, // Wide range
            887200,
            10000
        );

        assertTrue(tokenId > 0, "Liquidity mint failed");
        assertTrue(liquidity > 0, "Liquidity is zero");
    }

    function testBurnLiquidity() public {
        uint256 amount0 = 1 ether;
        uint256 amount1 = 2100 * 10 ** 18;

        deal(WETH, owner, amount0);
        deal(USDC, owner, amount1);

        IERC20(WETH).approve(address(liquidityManager), amount0);
        IERC20(USDC).approve(address(liquidityManager), amount1);

        (uint256 tokenId, uint128 liquidity) = liquidityManager.mintLiquidity(
            amount1,
            amount0,
            -887200,
            887200,
            10000
        );

        // UniswapV3LiquidityManager lm = UniswapV3LiquidityManager(
        //     0xCa316852334D35b3FB94379a86a6EEfAca49F9F0
        // );
        assertTrue(tokenId > 0, "Liquidity mint failed");
        // vm.prank(0x0DB63C9613b3BECf644A298AfECBa450795f612B);
        IUniswapV3NonfungiblePositionManager(POSITION_MANAGER).approve(
            address(lm),
            tokenId
        );

        vm.prank(0x0DB63C9613b3BECf644A298AfECBa450795f612B);
        lm.burnLiquidity(tokenId, liquidity);
    }

    function testRebalanceLiquidity() public {
        uint256 amount0 = 1 ether;
        uint256 amount1 = 2100 * 10 ** 18;

        deal(WETH, owner, amount0);
        deal(USDC, owner, amount1);

        IERC20(WETH).approve(address(liquidityManager), amount0);
        IERC20(USDC).approve(address(liquidityManager), amount1);

        (uint256 tokenId, uint128 liquidity) = liquidityManager.mintLiquidity(
            amount1,
            amount0,
            -887200,
            887200,
            10000
        );
        assertTrue(tokenId > 0, "Liquidity mint failed");

        IUniswapV3NonfungiblePositionManager(POSITION_MANAGER).approve(
            address(liquidityManager),
            tokenId
        );
        liquidityManager.rebalanceLiquidity(tokenId, liquidity, -60000, 60000);
    }
}
