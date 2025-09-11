// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EventToken is ERC20{
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 1000 * 10**18);
    }

    // 公开的 transfer 函数（可选，因为 ERC20 已有 transfer）
    function publicTransfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

}
