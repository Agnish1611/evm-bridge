// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract PortaBridge is Ownable {
    IERC20 public portaToken;

    mapping(address => uint256) public pendingBalance;

    event Deposit(address indexed user, uint256 amount);
    event PendingBalanceIncreased(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address _portaToken) Ownable(msg.sender) {
        portaToken = IERC20(_portaToken);
    }

    /// @notice Locks Porta tokens on this chain
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");
        require(portaToken.allowance(msg.sender, address(this)) >= amount, "Insufficient allowance");
        require(portaToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        emit Deposit(msg.sender, amount);
    }

    /// @notice Called by relayer when tokens are burned on opposite chain
    function burnedOnOppositeChain(address user, uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");
        pendingBalance[user] += amount;

        emit PendingBalanceIncreased(user, amount);
    }

    /// @notice Lets user withdraw tokens back after burn on other chain
    function withdraw(uint256 amount) external {
        require(pendingBalance[msg.sender] >= amount, "Insufficient pending balance");
        pendingBalance[msg.sender] -= amount;

        require(portaToken.transfer(msg.sender, amount), "Transfer failed");

        emit Withdraw(msg.sender, amount);
    }
}
