// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Base64 } from "solady/utils/Base64.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { BlindTrust } from "./BlindTrust.sol";
import { LibString } from "solady/utils/LibString.sol";
import { DateTimeLib } from "solady/utils/DateTimeLib.sol";
import { ENS } from "@ensdomains/ens-contracts/contracts/registry/ENS.sol";
import { IReverseRegistrar } from "@ensdomains/ens-contracts/contracts/reverseRegistrar/IReverseRegistrar.sol";
import { INameResolver } from "@ensdomains/ens-contracts/contracts/resolvers/profiles/INameResolver.sol";

/**
 * @title BlindTrustRenderer
 * @dev Contract for rendering metadata and SVG images for Blind Trust.
 */
contract BlindTrustRenderer is Ownable {
    string public metadata;

    BlindTrust public blindTrust;
    IERC1155 public ephemera;
    address public artistWallet;

    /**
     * @dev Constructor to initialize the contract with various parameters
     * @param _metadata Base metadata for the token
     * @param _ephemera Address of the ERC1155 contract for Ephemera
     * @param _artistWallet Address of the artist wallet
     */
    constructor(string memory _metadata, address _ephemera, address _artistWallet) Ownable() {
        metadata = _metadata;
        ephemera = IERC1155(_ephemera);
        artistWallet = _artistWallet;
    }

    /**
     * @dev Renders the complete metadata JSON for the token
     * @return string The base64 encoded metadata JSON
     */
    function renderMetadata() public view returns (string memory) {
        return string(abi.encodePacked("data:application/json;utf8,{", metadata, ', "image": "', renderImage(), '"}'));
    }

    /**
     * @dev Renders the SVG image for the token
     * @return string The base64 encoded SVG image
     */
    function renderImage() public view returns (string memory) {
        string memory svg = _getFullSVG();
        return string(abi.encodePacked("data:image/svg+xml;base64,", Base64.encode(bytes(svg))));
    }

    function _getFullSVG() internal view returns (string memory) {
        bool approved = ephemera.isApprovedForAll(getOwner(), artistWallet);

        return string(
            abi.encodePacked(
                '<svg width="100%" height="100%" viewBox="0 0 1000 1000" preserveAspectRatio="xMidYMid slice" fill="none" style="background: black;" xmlns="http://www.w3.org/2000/svg">',
                approved ? _getApprovedContent() : _getUnapprovedContent(),
                "</svg>"
            )
        );
    }

    function _getApprovedContent() internal pure returns (string memory) {
        return string(abi.encodePacked(_getSVGDefs(), _getWavesGroup()));
    }

    function _getUnapprovedContent() internal pure returns (string memory) {
        return '<rect x="0" y="485" width="1000" height="30" fill="white" />';
    }

    function _getSVGDefs() internal pure returns (string memory) {
        return string(
            abi.encodePacked(
                "<defs>",
                '<filter id="glow">',
                '<feGaussianBlur stdDeviation="0.5" result="coloredBlur" />',
                "<feMerge>",
                '<feMergeNode in="coloredBlur" />',
                '<feMergeNode in="SourceGraphic" />',
                "</feMerge>",
                "</filter>",
                "</defs>"
            )
        );
    }

    function _getWavesGroup() internal pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<g id="waves" filter="url(#glow)">',
                _getWavePath("wave1", "7s", "0s"),
                _getWavePath("wave2", "5s", "0s"),
                _getWavePath("wave3", "9s", "0s"),
                "</g>"
            )
        );
    }

    function _getWavePath(
        string memory id,
        string memory dur,
        string memory begin
    )
        internal
        pure
        returns (string memory)
    {
        return string(
            abi.encodePacked(
                '<path id="',
                id,
                '" d="M0,500 Q250,250 500,500 T1000,500" fill="none" stroke="white" stroke-width="2.5">',
                '<animate id="anim',
                id,
                '" attributeName="d" dur="',
                dur,
                '" repeatCount="indefinite" ',
                'values="M0,500 Q250,250 500,500 T1000,500; M0,500 Q250,750 500,500 T1000,500; M0,500 Q250,250 500,500 T1000,500" ',
                'calcMode="spline" keySplines="0.5 0 0.5 1; 0.5 0 0.5 1" begin="',
                begin,
                '" />',
                "</path>"
            )
        );
    }

    /**
     * @dev Retrieves the current owner of the token
     * @return address The address of the current owner
     */
    function getOwner() public view returns (address) {
        return blindTrust.currentOwner();
    }

    // Setter functions (onlyOwner)
    function setBlindTrust(address _blindTrust) external onlyOwner {
        blindTrust = BlindTrust(_blindTrust);
    }

    function setEphemera(address _ephemera) external onlyOwner {
        ephemera = IERC1155(_ephemera);
    }

    function setMetadata(string memory _metadata) external onlyOwner {
        metadata = _metadata;
    }
}
