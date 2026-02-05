// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
contract WZToken is ERC20{
    address public owner;
    event Mint(address indexed ,uint256 indexed );
    event Burn(address indexed, uint256 indexed );
    constructor(address _owner) ERC20("ZToken", "ZT"){
        owner = _owner;
    }
    function changeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }
    modifier onlyOwner() {
        require (msg.sender == owner,"OnlyOwner function");
        _;
    }
    function mint(address to, uint256 value) external onlyOwner {
        _mint(to,value);
        emit Mint(to, value);
    }
    function burn(address from, uint256 value) external onlyOwner {
        _burn(from, value);
        emit Burn(from, value);
    }
}