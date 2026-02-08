// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
Just a normal ERC20 contract with createToken function to mint tokens. Though it is not a very practical contract 
* but it is just for Learning Purpose. Owner has the ability to mint as many tokens he can.
*/
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract ZToken is ERC20{
    address public owner;

    constructor(address _owner) ERC20("ZToken", "ZT"){
        owner = _owner;
    }

    modifier onlyOwner() {
    require (msg.sender == owner, "OnlyOwner can do this OPeration" );
    _;
}

function createToken(address account, uint256 value) public  onlyOwner {
    _mint(account, value);
}

}

