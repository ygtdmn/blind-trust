// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

import { IERC721CreatorCore } from "@manifoldxyz/creator-core-solidity/contracts/core/IERC721CreatorCore.sol";
import { IERC1155CreatorCore } from "@manifoldxyz/creator-core-solidity/contracts/core/IERC1155CreatorCore.sol";
import { ICreatorExtensionTokenURI } from
    "@manifoldxyz/creator-core-solidity/contracts/extensions/ICreatorExtensionTokenURI.sol";
import { IERC1155CreatorExtensionApproveTransfer } from
    "@manifoldxyz/creator-core-solidity/contracts/extensions/ERC1155/IERC1155CreatorExtensionApproveTransfer.sol";
import { IERC165, ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import { ERC165Checker } from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { BlindTrustRenderer } from "./BlindTrustRenderer.sol";

/**
 * @title Blind Trust
 * @notice Blind Trust is an on-chain experiment on trust between artist and collector.
 */
contract BlindTrust is ICreatorExtensionTokenURI, IERC1155CreatorExtensionApproveTransfer, ERC165, Ownable {
    BlindTrustRenderer public metadataRenderer;
    address public creatorContractAddress;
    uint256 public tokenId;
    address public currentOwner;

    /**
     * @dev Constructor initializes the contract with a metadata renderer and creator contract address.
     * @param _metadataRenderer Address of the BlindTrustRenderer contract
     * @param _creatorContractAddress Address of the creator contract
     */
    constructor(address _metadataRenderer, address _creatorContractAddress) Ownable() {
        metadataRenderer = BlindTrustRenderer(_metadataRenderer);
        creatorContractAddress = _creatorContractAddress;
    }

    /**
     * @dev Allows the owner to set a new metadata renderer.
     * @param _metadataRenderer Address of the new BlindTrustRenderer contract
     */
    function setMetadataRenderer(address _metadataRenderer) public onlyOwner {
        metadataRenderer = BlindTrustRenderer(_metadataRenderer);
    }

    /**
     * @dev Allows the owner to set a new creator contract address.
     * @param _creatorContractAddress Address of the new creator contract
     */
    function setCreatorContractAddress(address _creatorContractAddress) public onlyOwner {
        creatorContractAddress = _creatorContractAddress;
    }

    /**
     * @dev Returns the metadata for the given token.
     * @return string The metadata URI for the token
     */
    function tokenURI(address, uint256) external view override returns (string memory) {
        return metadataRenderer.renderMetadata();
    }

    /**
     * @dev Mints a new token to the contract owner. Can only be called once.
     */
    function mint() external onlyOwner {
        require(tokenId == 0, "Already minted");
        address[] memory dest = new address[](1);
        uint256[] memory quantities = new uint256[](1);
        string[] memory uris = new string[](1);

        dest[0] = msg.sender;
        quantities[0] = 1;

        tokenId = IERC1155CreatorCore(creatorContractAddress).mintExtensionNew(dest, quantities, uris)[0];
        currentOwner = msg.sender;
    }

    /**
     * @dev Checks if the contract supports a given interface.
     * @param interfaceId The interface identifier to check
     * @return bool True if the interface is supported, false otherwise
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(ICreatorExtensionTokenURI).interfaceId
            || interfaceId == type(IERC1155CreatorExtensionApproveTransfer).interfaceId
            || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Sets the approve transfer status for the creator contract.
     * @param creator Address of the creator contract
     * @param enabled Boolean indicating whether to enable or disable approve transfer
     */
    function setApproveTransfer(address creator, bool enabled) external override {
        require(
            ERC165Checker.supportsInterface(creator, type(IERC1155CreatorCore).interfaceId),
            "creator must implement IERC1155CreatorCore"
        );
        require(creator == creatorContractAddress, "creator must be the creator contract address");
        IERC1155CreatorCore(creator).setApproveTransferExtension(enabled);
    }

    /**
     * @dev Approves token transfers and updates the current owner.
     * @param from Address transferring the token
     * @param to Address receiving the token
     * @return bool Always returns true to approve the transfer
     */
    function approveTransfer(
        address,
        address from,
        address to,
        uint256[] calldata,
        uint256[] calldata
    )
        external
        override
        returns (bool)
    {
        if (from != to) {
            currentOwner = to;
        }
        return true;
    }
}
