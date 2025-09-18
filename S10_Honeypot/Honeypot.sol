// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
 
// 极简貔貅ERC20代币，只能买，不能卖
contract HoneyPot is ERC20, Ownable {
    address public pair;
    // 构造函数：初始化代币名称和代号
    constructor() ERC20("WWP1", "WWP1") Ownable(msg.sender){
        
    }

    function decimals() public view virtual override returns (uint8) {
        return 2;
    }
    
    function mint(address to, uint amount) public onlyOwner {
        _mint(to, amount);
    }

    function _update(
      address from,
      address to,
      uint256 amount
  ) internal virtual override {
      super._update(from, to, amount);
  }
}