// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract ToolsTest {
    
    function hashSelector(string memory msign) external pure returns(bytes32){
        return keccak256(bytes(msign));
    }

    function byte4Selector(string memory msign) external pure returns(bytes4){
        return bytes4(keccak256(bytes(msign)));
    }

    function encodeAbi(bytes4 msign) external pure returns(bytes memory){
        return abi.encodeWithSelector(msign);
    }

    function encodeAbi(bytes4 msign, address addr, uint256 amount) external pure returns(bytes memory){
        return abi.encodeWithSelector(msign, addr, amount);
    }

    function convertToBytes(string memory str) external pure returns(bytes memory){
        return bytes(str);
    }
}
