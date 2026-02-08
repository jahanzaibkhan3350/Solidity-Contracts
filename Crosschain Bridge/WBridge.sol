// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
This contract unlocks Wrap Tokens, when user deposit tokens on the other bridge their tokens are locked there and new tokens
* are minted here. These two contracts works on Lock and Mint mechanism. 
*/
// imported an interface with mint and burn functions

import {IERC20} from "../Interface/extendedIERC20.sol";

contract DestinationBridge{
/*
_owner will be address of the external party which will monitor events on first bridge contract to call unlock function here
*/
    IERC20 private WZToken;

    address private _owner;

    constructor(address adr, address owner) {
        WZToken = IERC20(adr);
        _owner = owner;
    }
    /*
    _balances to track the balances of the users. Locked event for the external party, so it can call withdrawTokens function on the
    * fisrt bridge contract.
    * See {bridge.sol}.
    */
    mapping (address => uint256) private _balances;

    event Locked(address indexed user, uint256 indexed amount);
    /*
    Only the external party can call this function, after the user will call depositTokens function on the first bridge which emits
    * an event.
    * See {bridge.sol}
    */
    function unlock(address user, uint256 amount) public authorizedOnly {
        WZToken.mint(user, amount);
        _balances[user] += amount;
    }
    /*
    User call this function to unlock there tokens on the other chain (on the first bridge). There current tokens will be burned
    */
    function lock(address user, uint256 amount) external {
        require(amount <= _balances[user] && amount > 0, "Insufficient Funds");
        _balances[user] -= amount;
        WZToken.burn(user, amount);
        emit Locked(user, amount);
    }
    // A modifier so only the external party can call some critical functions
    modifier authorizedOnly(){
        require(msg.sender == _owner, "Authorized Only Function");
        _;
    }
}

