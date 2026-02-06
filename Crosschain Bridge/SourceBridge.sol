// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*imported an IERC20 interface having some extra functions
to support the functionality of the bridge*/
import {IERC20} from "../Interface/extendedIERC20.sol";

contract SourceBridge{
// Declare the Interface by a name
    IERC20 private ZToken;
/* Add the address of the ERC20 token which you want to 
lock, in oder to mint other token on the other chain. */
    constructor(address adr) {
        ZToken = IERC20(adr);
    }
/* _balances to track the balance of each user and
totalLiquidity to track the total balance of the bridge. */

mapping (address => uint256 ) private _balances;
uint256 public totalLiquidity;

/* Deposit and Withdraw event are for the Script to
catch any activity on source bridge and perform 
transaction on the Destination Bridge. */

event Deposit(address indexed user, uint256 indexed amount);
event Withdraw(address indexed , uint256 indexed);

/* This is the core function when a user call this function
the tokens are transferred from its account to the contract 
itself and an event is emited which is the most important 
thing, by this event the external detect this deposit and 
performs transfer from the destinationBridge contract and 
the user will get equivalent token on the destination chain. */
// Important: Make sure to Approve SourceBridge Contract if
you are doing all the stuff manually.

function depositTokens(uint256 amount) public {
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




