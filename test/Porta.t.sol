// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/Porta.sol";

contract PortaTest is Test {
    Porta public porta;
    address public owner = address(0xAB);
    address public user = address(0xCD);

    function setUp() public {
        vm.prank(owner);
        porta = new Porta();
    }

    function testInitialMintToOwner() public {
        assertEq(porta.balanceOf(owner), 1_000_000 * 10 ** porta.decimals());
    }

    function testTransfer() public {
        uint256 amount = 100 * 10 ** porta.decimals();

        vm.prank(owner);
        porta.transfer(user, amount);

        assertEq(porta.balanceOf(user), amount);
    }
}
