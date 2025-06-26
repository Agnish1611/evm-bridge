// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

interface IWrappedPorta {
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}

contract WrappedPortaBridge is Ownable {
    IWrappedPorta public wrappedToken;

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount, string targetAddress);

    constructor(address _wrappedToken) Ownable(msg.sender) {
        wrappedToken = IWrappedPorta(_wrappedToken);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(amount > 0, "Invalid amount");
        wrappedToken.mint(to, amount);
        emit Mint(to, amount);
    }

    function burn(uint256 amount, string calldata targetAddress) external {
        require(amount > 0, "Amount must be > 0");
        wrappedToken.burn(msg.sender, amount);
        emit Burn(msg.sender, amount, targetAddress);
    }
}
