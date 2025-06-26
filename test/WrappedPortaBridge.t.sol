// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/WrappedPorta.sol";
import "../src/WrappedPortaBridge.sol";

contract WrappedPortaBridgeTest is Test {
    WrappedPorta public wrapped;
    WrappedPortaBridge public bridge;
    address public user = address(2);

    function setUp() public {
        wrapped = new WrappedPorta();
        bridge = new WrappedPortaBridge(address(wrapped));
        wrapped.setBridge(address(bridge));
    }

    function testMintWorksFromOwner() public {
        bridge.mint(user, 100 ether);
        assertEq(wrapped.balanceOf(user), 100 ether);
    }

    function testMintFailsIfNotOwner() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        bridge.mint(user, 100 ether);
    }

    function testBurnWorksFromUser() public {
        // Mint first
        bridge.mint(user, 200 ether);
        assertEq(wrapped.balanceOf(user), 200 ether);

        // Burn
        vm.prank(user);
        bridge.burn(50 ether, "0xYourSepoliaAddress");

        assertEq(wrapped.balanceOf(user), 150 ether);
    }

    function testBurnFailsIfNotEnoughBalance() public {
        vm.prank(user);
        vm.expectRevert(); // Will revert in `burn()` of token
        bridge.burn(100 ether, "0xFail");
    }
}
