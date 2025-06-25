// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract WrappedPorta is ERC20, Ownable {
    address public bridge;

    constructor() ERC20("Wrapped Porta", "wPRT") Ownable(msg.sender) {}

    modifier onlyBridge() {
        require(msg.sender == bridge, "Caller is not the bridge");
        _;
    }

    function setBridge(address _bridge) external onlyOwner {
        require(bridge == address(0), "Bridge already set");
        bridge = _bridge;
    }

    function mint(address to, uint256 amount) external onlyBridge {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyBridge {
        _burn(from, amount);
    }
}