// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MerkleTree {
    /*
    1st: keccak256(1) = 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
    2nd: keccak256(2) = 0x405787fa12a823e0f2b7631cc41b3ba8828b3321ca811111fa75cd3aa3bb5ace
    3rd: keccak256(3) = 0xc2575a0e9e593c00f959f8c92f12db2869c3395a3b0502d05e2516446f71f85b
    4th: keccak256(4) = 0x8a35acfbc15ff81a39ae7d344fd709f28e8600b4aa8c65c6b64bfe7fe36bd19b
    5th: keccak256(keccak256(1) , keccak256(2)) = 0x50387073e2d4f7060a3c02c3c5268d8a72700a28b5cbd7e23314ae0e1ebda895
    6th: keccak256(keccak256(3) , keccak256(4)) = 0x4a008209643838d588e1e3949a8a49c2dc4dfb50ee6aab985a7cf6eccba95084
    7th: keccak256(keccak256(keccak256(1) , keccak256(2)), keccak256(keccak256(3) , keccak256(4)))= 
         0x1e8cc8511a4954df48a80e5f5b8da3419a99ba3e7697574234e10893022167fc
    */

    /*
     * Let say the leaf we want to find is the 3rd hash then we will provide the 4th hash & 5th hash in the proofs array
     * the index will be 2 and the root will be the 7th hash
     */
    function calculateHash(
        bytes32[] memory proofs,
        bytes32 root,
        bytes32 leaf,
        uint256 index
    ) public pure returns (bool) {
        bytes32 hash = leaf;
        for (uint i = 0; i < proofs.length; i++) {
            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofs[i]));
            } else {
                hash = keccak256(abi.encodePacked(proofs[i], hash));
            }
            index = index / 2;
        }
        return hash == root;
    }
}
