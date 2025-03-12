// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "../src/UniswapPositionManager.sol";

contract DeployUniswapManagerMonad is Script {
    address constant POSITION_MANAGER =
        0x3dCc735C74F10FE2B9db2BB55C40fbBbf24490f7; // Uniswap V3 Position Manager

    function run() external {
        // Start broadcasting the transaction (so we can sign and send it)
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        UniswapV3LiquidityManager lm = new UniswapV3LiquidityManager(
            POSITION_MANAGER
        );

        // Stop broadcasting
        vm.stopBroadcast();
    }
}
