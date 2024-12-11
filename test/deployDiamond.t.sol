// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/Diamond.sol";
import "./helpers/DiamondUtils.sol";

import {AirdropFactoryFacet} from "../contracts/facets/erc20facets/FactoryFacet.sol";
import {PoapFactoryFacet} from "../contracts/facets/erc721facets/PoapFactoryFacet.sol";

contract DiamondDeployer is DiamondUtils, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    AirdropFactoryFacet factoryF;
    PoapFactoryFacet poapFactoryF;

    function setUp() public {
        //deploy facets

        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        poapFactoryF = new PoapFactoryFacet();
        factoryF = new AirdropFactoryFacet();
        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](4);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(factoryF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("AirdropFactoryFacet")
            })
        );
        cut[3] = (
            FacetCut({
                facetAddress: address(factoryF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("PoapFactoryFacet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();

        // // deploy test erc20
        // vm.prank(owner);
        // shibuyaToken = new TestERC20("ShibuyaToken", "SHIB");

        // assertEq(shibuyaToken.balanceOf(owner), 100000e18);

        // //interact with factory
        // address[] memory addresses = AirdropFactoryFacet(address(diamond)).getAllSonikDropClones();
        // assertEq(addresses.length, 0);

        // // create sonik token drop without NFT
        // address _tokenAddress = address(shibuyaToken);
        // bytes32 _merkleRoot = 0x29c08bc8bf7d3a0ed4b1dd16063389608cf9dec220f1584e32d317c2041e1fa4;
        // uint256 _noOfClaimers = 100;
        // uint256 _totalOutputTokens = 10000e18;

        // // should revert without tokenApproval
        // vm.expectRevert();
        // AirdropFactoryFacet(address(diamond)).createSonikDrop(
        //     _tokenAddress, _merkleRoot, _noOfClaimers, _totalOutputTokens
        // );

        // // approve token
        // vm.startPrank(owner);
        // shibuyaToken.approve(address(diamond), 50000e18);

        // assertEq(shibuyaToken.allowance(owner, address(diamond)), 50000e18);

        // // create sonik contract
        // LibDiamond.SonikDropObj memory sonikDropObj = AirdropFactoryFacet(address(diamond)).createSonikDrop(
        //     _tokenAddress, _merkleRoot, _noOfClaimers, _totalOutputTokens
        // );
        // assertEq(sonikDropObj.nftAddress, address(0));
        // assertEq(sonikDropObj.tokenAddress, _tokenAddress);
        // assertEq(sonikDropObj.owner, owner);
        // assertEq(sonikDropObj.merkleRoot, _merkleRoot);

        // // test claiming
        // assertEq(shibuyaToken.balanceOf(sonikDropObj.contractAddress), _totalOutputTokens);

        // should we make the sonikFacet depend on diamond or have it's own storage
    }

    function testDiamond() public {}

    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external override {}
}
