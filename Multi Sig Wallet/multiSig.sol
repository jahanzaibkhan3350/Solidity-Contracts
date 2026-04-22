// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    
    event Deposit(address indexed sender, uint256 amount);
    event SubmitTransaction(uint256 indexed txId, address indexed to, uint256 value, bytes data);
    event ApproveTransaction(address indexed owner, uint256 indexed txId);
    event RevokeApproval(address indexed owner, uint256 indexed txId);
    event ExecuteTransaction(uint256 indexed txId);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public requiredApprovals;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 approvalCount;
    }

    Transaction[] public transactions;
    // txId => owner => approved
    mapping(uint256 => mapping(address => bool)) public approved;

    // Modifiers For Access Control 
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    modifier txExists(uint256 txId) {
        require(txId < transactions.length, "Tx does not exist");
        _;
    }

    modifier notExecuted(uint256 txId) {
        require(!transactions[txId].executed, "Tx already executed");
        _;
    }

    modifier notApproved(uint256 txId) {
        require(!approved[txId][msg.sender], "Tx already approved");
        _;
    }
 
    constructor(address[] memory _owners, uint256 _requiredApprovals) {
        require(_owners.length > 0, "Owners required");
        require( _requiredApprovals > 0 && _requiredApprovals <= _owners.length, "Invalid approval count");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");

            isOwner[owner] = true;
            owners.push(owner);
        }

        requiredApprovals = _requiredApprovals;
    }

    // Receive Ether
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Any owner submits a transaction proposal
    function submitTransaction(address _to, uint256 _value, bytes calldata _data) external onlyOwner returns (uint txId){
        txId = transactions.length;
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            approvalCount: 0
        }));

        emit SubmitTransaction(txId, _to, _value, _data);
    }

    /// @notice Owner approves a pending transaction
    function approveTransaction(uint256 txId) external onlyOwner txExists(txId) notExecuted(txId) notApproved(txId){
        approved[txId][msg.sender] = true;
        transactions[txId].approvalCount++;

        emit ApproveTransaction(msg.sender, txId);
    }

    /// @notice Execute once enough approvals are collected
    function executeTransaction(uint256 txId) external onlyOwner txExists(txId) notExecuted(txId){
        Transaction storage txn = transactions[txId];
        require(txn.approvalCount >= requiredApprovals, "Not enough approvals");

        txn.executed = true;

        (bool success, ) = txn.to.call{value: txn.value}(txn.data);
        require(success, "Tx failed");

        emit ExecuteTransaction(txId);
    }

    /// @notice Owner revokes their approval before execution
    function revokeApproval(uint256 txId) external onlyOwner txExists(txId) notExecuted(txId){
        require(approved[txId][msg.sender], "Tx not approved");

        approved[txId][msg.sender] = false;
        transactions[txId].approvalCount--;

        emit RevokeApproval(msg.sender, txId);
    }

    // Helper Functions
    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function getTransaction(uint256 txId) external view returns 
    (address to, uint256 value, bytes memory data, bool executed, uint256 approvalCount){
        Transaction storage txn = transactions[txId];
        return (txn.to, txn.value, txn.data, txn.executed, txn.approvalCount);
    }
}
