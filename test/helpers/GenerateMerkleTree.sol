// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Merkle} from "murky/src/Merkle.sol";

abstract contract GenerateMerkleTree {
    function _generateLeaves(address[] memory _addresses) internal pure returns (bytes32[] memory) {
        bytes32[] memory leaves = new bytes32[](_addresses.length);
        for (uint256 i = 0; i < _addresses.length; i++) {
            leaves[i] = keccak256(abi.encodePacked(_addresses[i]));
        }
        return leaves;
    }

    function _generateLeavesWithValues(address[] memory _addresses, uint256[] memory _values)
        internal
        pure
        returns (bytes32[] memory)
    {
        bytes32[] memory leaves = new bytes32[](_addresses.length);
        for (uint256 i = 0; i < _addresses.length; i++) {
            leaves[i] = keccak256(abi.encodePacked(_addresses[i], _values[i]));
        }
        return leaves;
    }

    function generateMerkleTree(address[] memory _addresses) public returns (bytes32) {
        Merkle merkle = new Merkle();
        bytes32[] memory leaves = _generateLeaves(_addresses);
        return merkle.getRoot(leaves);
    }

    function generateMerkleTreeWithValues(address[] memory _addresses, uint256[] memory _values)
        public
        returns (bytes32)
    {
        Merkle merkle = new Merkle();
        bytes32[] memory leaves = _generateLeavesWithValues(_addresses, _values);
        return merkle.getRoot(leaves);
    }

    function generateMerkleProof(address[] memory _addresses, uint256 index)
        public
        returns (bytes32 root, bytes32[] memory proof)
    {
        Merkle merkle = new Merkle();
        bytes32[] memory leaves = _generateLeaves(_addresses);
        root = merkle.getRoot(leaves);
        proof = merkle.getProof(leaves, index);
    }

    function generateMerkleProofWithValues(address[] memory _addresses, uint256[] memory _values, uint256 index)
        public
        returns (bytes32 root, bytes32[] memory proof)
    {
        Merkle merkle = new Merkle();
        bytes32[] memory leaves = _generateLeavesWithValues(_addresses, _values);
        root = merkle.getRoot(leaves);
        proof = merkle.getProof(leaves, index);
    }
}
