// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "./Interface/extendedIERC20.sol";

contract SourceBridge{
    IERC20 private ZToken;
    constructor(address adr) {
        ZToken = IERC20(adr);
    }
    mapping (address => uint256 ) private _balances;
    uint256 public totalLiquidity;
    event Deposit(address indexed user,uint256 indexed amount);
    event Withdraw(address indexed ,uint256 indexed );
    function depositTokens( uint256 amount) public {
        require(amount > 0, "Cannot be Zero");
        ZToken.transferFrom(msg.sender, address(this), amount);
        _balances[msg.sender] += amount;
        totalLiquidity += amount;
        emit Deposit(msg.sender, amount);
    }
    function withdrawTokens(address user, uint256 amount) public {
        require(msg.sender == address(this),"invalid operation");
        require(amount <= _balances[user], "Invalid Amount");
        ZToken.transfer(user, amount);
        _balances[user] -= amount;
        totalLiquidity -= amount;
        emit Withdraw(user, amount);
    }

}
