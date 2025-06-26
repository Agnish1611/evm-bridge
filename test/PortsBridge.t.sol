// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PortaBridge.sol";
import "../src/Porta.sol";

contract PortaBridgeTest is Test {
    Porta public porta;
    PortaBridge public bridge;
    address public user = address(1);
    address public relayer = address(this);

    function setUp() public {
        porta = new Porta();
        bridge = new PortaBridge(address(porta));

        // Give user some tokens and approve the bridge
        porta.transfer(user, 1000 ether);
        vm.prank(user);
        porta.approve(address(bridge), 1000 ether);
    }

    function testDepositTransfersTokensToBridge() public {
        vm.prank(user);
        bridge.deposit(100 ether);

        assertEq(porta.balanceOf(address(bridge)), 100 ether);
        assertEq(porta.balanceOf(user), 900 ether);
    }

    function testDepositFailsIfNoApproval() public {
        vm.prank(user);
        bridge = new PortaBridge(address(porta)); // New bridge not approved

        vm.expectRevert("Insufficient allowance");
        bridge.deposit(100 ether);
    }

    function testBurnedOnOppositeChainAddsPendingBalance() public {
        bridge.burnedOnOppositeChain(user, 123 ether);
        assertEq(bridge.pendingBalance(user), 123 ether);
    }

    function testWithdrawTransfersPendingBalance() public {
        // Fund the bridge with enough Porta tokens for withdrawal
        porta.transfer(address(bridge), 500 ether);

        bridge.burnedOnOppositeChain(user, 123 ether);

        uint256 before = porta.balanceOf(user);
        vm.prank(user);
        bridge.withdraw(123 ether);

        assertEq(porta.balanceOf(user), before + 123 ether);
        assertEq(bridge.pendingBalance(user), 0);
    }

    function testWithdrawFailsIfNotEnoughBalance() public {
        vm.prank(user);
        vm.expectRevert("Insufficient pending balance");
        bridge.withdraw(1 ether);
    }
}
