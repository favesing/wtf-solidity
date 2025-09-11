// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract UniswapCodeTest{
    
    function testBlockTimestamp() public view returns(uint256[2] memory){
        // 2**32 => 2^32 -1
        uint256 orgBlockTimestamp = block.timestamp;
        uint32 newBlockTimestamp = uint32(orgBlockTimestamp % 2**32);
        return [orgBlockTimestamp, newBlockTimestamp];
    }

}
