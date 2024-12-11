// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {LibDiamond} from "../../libraries/LibDiamond.sol";
import {IERC20} from "../../interfaces/IERC20.sol";
import {SonikDrop} from "./SonikDrop.sol";
import {Errors, Events} from "../../libraries/Utils.sol";

contract AirdropFactoryFacet {
    //  when a person interacts with the factory, he would options like
    // 1. Adding an NFT requirement
    // 2. Adding a time lock

    function _createSonikDrop(
        address _tokenAddress,
        bytes32 _merkleRoot,
        address _nftAddress,
        uint256 _claimTime,
        uint256 _noOfClaimers,
        uint256 _totalOutputTokens
    ) private returns (address) {
        if (msg.sender == address(0)) {
            revert Errors.ZeroAddressDetected();
        }
        if (_noOfClaimers <= 0) {
            revert Errors.ZeroValueDetected();
        }

        if (_totalOutputTokens <= 0) {
            revert Errors.ZeroValueDetected();
        }

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        SonikDrop _newSonik =
            new SonikDrop(msg.sender, _tokenAddress, _merkleRoot, _nftAddress, _claimTime, _noOfClaimers);

        bool success = IERC20(_tokenAddress).transferFrom(msg.sender, address(_newSonik), _totalOutputTokens);
        require(success, Errors.TransferFailed());

        ds.ownerToSonikDropCloneContracts[msg.sender].push(address(_newSonik));

        ds.allSonikDropClones.push(address(_newSonik));
        ++ds.cloneCount;

        emit Events.SonikCloneCreated(msg.sender, block.timestamp, address(_newSonik));

        return address(_newSonik);
    }

    function createSonikDrop(
        address _tokenAddress,
        bytes32 _merkleRoot,
        address _nftAddress,
        uint256 _noOfClaimers,
        uint256 _totalOutputTokens
    ) external returns (address) {
        return _createSonikDrop(_tokenAddress, _merkleRoot, _nftAddress, 0, _noOfClaimers, _totalOutputTokens);
    }

    function createSonikDrop(
        address _tokenAddress,
        bytes32 _merkleRoot,
        uint256 _noOfClaimers,
        uint256 _totalOutputTokens
    ) external returns (address) {
        return _createSonikDrop(_tokenAddress, _merkleRoot, address(0), 0, _noOfClaimers, _totalOutputTokens);
    }

    function getOwnerSonikDropClones(address _owner) external view returns (address[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.ownerToSonikDropCloneContracts[_owner];
    }

    function getAllSonikDropClones() external view returns (address[] memory) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        return ds.allSonikDropClones;
    }
}
