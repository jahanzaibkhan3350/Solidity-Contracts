// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./extendedIERC20.sol";

contract DestinationBridge{
    IERC20 private WZToken;
    constructor(address adr) {
        WZToken = IERC20(adr);
    }
    mapping (address => uint256) private _balances;
    function unlock(address user, uint256 amount) public {
        WZToken.mint(user, amount);
        _balances[user] += amount;
    }
}