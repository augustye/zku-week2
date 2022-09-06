//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    uint256 constant MAX_LEVEL = 3; //total 2**3 leaves

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        for(uint256 i=0; i<2**MAX_LEVEL; i++) {
            hashes.push(0);
        } 

        uint256 lastLevelStart = 0;
        uint256 currentLevelStart = 0;
        for(uint256 level=MAX_LEVEL-1; ;level--) {
            currentLevelStart += 2**(level+1);
            for(uint256 i=0; i<2**level; i++) {
                hashes.push(0);
                updateHash(currentLevelStart, lastLevelStart, i);
            } 
            lastLevelStart = currentLevelStart;
            if(level==0) break;
        }

        root = hashes[hashes.length - 1];
    }

    function updateHash(uint256 currentLevelStart, uint256 lastLevelStart, uint256 levelIndex) private {
        uint256[2] memory input;
        input[0] = hashes[lastLevelStart + levelIndex*2 + 0];
        input[1] = hashes[lastLevelStart + levelIndex*2 + 1];
        hashes[currentLevelStart+levelIndex] = PoseidonT3.poseidon(input);
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        require(index < 2**MAX_LEVEL);
        hashes[index] = hashedLeaf;
        uint256 levelIndex = index;
        index++;

        uint256 lastLevelStart = 0;
        uint256 currentLevelStart = 0;
        for(uint256 level=MAX_LEVEL-1; ;level--) {
            currentLevelStart += 2**(level+1);
            levelIndex /= 2;
            updateHash(currentLevelStart, lastLevelStart, levelIndex);
            lastLevelStart = currentLevelStart;
            if(level==0) break;
        }

        root = hashes[hashes.length - 1];
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return root == input[0] && verifyProof(a, b, c, input);
    }
}
