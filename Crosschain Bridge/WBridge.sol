// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This is the bridge contract which will be called by an external party. 

import {IERC20} from "../Interface/extendedIERC20.sol";

contract DestinationBridge{
    IERC20 private WZToken;
    address private _owner;
    constructor(address adr, address owner) {
        WZToken = IERC20(adr);
        _owner = owner;
    }
    mapping (address => uint256) private _balances;
    function unlock(address user, uint256 amount) public authorizedOnly {
        WZToken.mint(user, amount);
        _balances[user] += amount;
    }
    modifier authorizedOnly(){
        require(msg.sender == _owner, "Authorized Only Function");
        _;
    }
}
