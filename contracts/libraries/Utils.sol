// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC721TokenReceiver} from "../interfaces/IERC721TokenReceiver.sol";

library Errors {
    // @dev Custom errors
    error ZeroAddressDetected();
    error HasClaimedRewardsAlready();
    error UnAuthorizedFunctionCall();
    error InvalidClaim();
    error ZeroValueDetected();
    error UnclaimedTokensStillMuch();
    error WithdrawalFailed();
    error TransferFailed();
    error CannotSetOwnerTwice();
    error CannotSetAddressTwice();
    error NFTNotFound();
    error AirdropClaimEnded();
    error AirdropClaimTimeNotEnded();
    error TotalClaimersExceeded();
    error InsufficientContractBalance();
    error InvalidSignature();
    error InvalidTokenId();
}

library Events {
    // @dev events
    event AirdropClaimed(address indexed _user, uint256 indexed _amount);

    event WithdrawalSuccessful(address indexed _owner, uint256 indexed _amount);
    event SonikPoapCloneCreated(address indexed _owner, uint256 indexed _timestamp, address indexed _sonikPoapClone);
    event MerkleRootUpdated(bytes32 indexed _oldMerkleRoot, bytes32 indexed _newMerkleRoot);
    event OwnershipTransferred(address indexed _oldOwner, uint256 indexed _timestamp, address indexed _newOwner);
    event AirdropTokenDeposited(address indexed _owner, uint256 indexed _amount);
    event NftRequirementToggled(address indexed _owner, uint256 indexed _timestamp);

    event NftRequirementUpdated(address indexed _owner, uint256 indexed _timestamp, address indexed _newNft);
    event ClaimTimeUpdated(address indexed _owner, uint256 indexed _newClaimTimeDuration, uint256 indexed _newDeadline);

    event SonikCloneCreated(address indexed _owner, uint256 indexed _timestamp, address indexed _sonikClone);

    event ClaimersNumberUpdated(address indexed _owner, uint256 indexed _timestamp, uint256 indexed _newClaimersNumber);
}

library IERC721Errors {
    error CannotReinitializeToken();
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in ERC-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

library ERC721Utils {
    /**
     * @dev Performs an acceptance check for the provided `operator` by calling {IERC721-onERC721Received}
     * on the `to` address. The `operator` is generally the address that initiated the token transfer (i.e. `msg.sender`).
     *
     * The acceptance call is not executed and treated as a no-op if the target address doesn't contain code (i.e. an EOA).
     * Otherwise, the recipient must implement {IERC721Receiver-onERC721Received} and return the acceptance magic value to accept
     * the transfer.
     */
    function checkOnERC721Received(address operator, address from, address to, uint256 tokenId, bytes memory data)
        internal
    {
        if (to.code.length > 0) {
            try IERC721TokenReceiver(to).onERC721Received(operator, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721TokenReceiver.onERC721Received.selector) {
                    // Token rejected
                    revert IERC721Errors.ERC721InvalidReceiver(to);
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    // non-IERC721Receiver implementer
                    revert IERC721Errors.ERC721InvalidReceiver(to);
                } else {
                    assembly ("memory-safe") {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        }
    }
}
