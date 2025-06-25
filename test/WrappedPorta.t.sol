// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/WrappedPorta.sol";

contract WrappedPortaTest is Test {
    WrappedPorta public wrapped;
    address public owner = address(0xAB);
    address public bridge = address(0xCD);
    address public user = address(0xEF);

    function setUp() public {
        vm.prank(owner);
        wrapped = new WrappedPorta();
        vm.prank(owner);
        wrapped.transferOwnership(owner);

        vm.prank(owner);
        wrapped.setBridge(bridge);
    }

    function testOnlyBridgeCanMint() public {
        uint256 amount = 1000 * 10 ** wrapped.decimals();

        vm.prank(bridge);
        wrapped.mint(user, amount);

        assertEq(wrapped.balanceOf(user), amount);
    }

    function testNonBridgeCannotMint() public {
        vm.expectRevert("Caller is not the bridge");
        vm.prank(user);
        wrapped.mint(user, 1000);
    }

    function testOnlyBridgeCanBurn() public {
        uint256 amount = 500 * 10 ** wrapped.decimals();

        vm.prank(bridge);
        wrapped.mint(user, amount);

        assertEq(wrapped.balanceOf(user), amount);

        vm.prank(bridge);
        wrapped.burn(user, amount);

        assertEq(wrapped.balanceOf(user), 0);
    }

    function testCannotSetBridgeTwice() public {
        vm.expectRevert("Bridge already set");
        vm.prank(owner);
        wrapped.setBridge(address(0x123));
    }
}