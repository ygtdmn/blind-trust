// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { BlindTrustRenderer } from "../src/BlindTrustRenderer.sol";
import { BlindTrust } from "../src/BlindTrust.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { IEphemera } from "./interfaces/IEphemera.sol";

contract BlindTrustRendererTest is Test {
    function testFork_Example() external {
        // Silently pass this test if there is no API key.
        string memory alchemyApiKey = vm.envOr("API_KEY_ALCHEMY", string(""));
        if (bytes(alchemyApiKey).length == 0) {
            return;
        }

        // Otherwise, run the test against the mainnet fork.
        vm.createSelectFork({ urlOrAlias: "mainnet" });
        vm.startPrank(address(0x28996f7DECe7E058EBfC56dFa9371825fBfa515A));

        IEphemera ephemera = IEphemera(address(0xCb337152b6181683010D07e3f00e7508cd348BC7));
        BlindTrustRenderer renderer =
            new BlindTrustRenderer("", address(ephemera), address(0x077be47506ABa13F54b20850fd47d1Cea69d84A5));
        BlindTrust blindTrust = new BlindTrust(address(renderer), address(ephemera));
        ephemera.registerExtension(address(blindTrust), "");
        renderer.setBlindTrust(address(blindTrust));
        blindTrust.mint();
        IERC1155(address(ephemera)).setApprovalForAll(address(0x077be47506ABa13F54b20850fd47d1Cea69d84A5), false);
        string memory image = renderer.renderImage();
        console2.log(image);
    }
}
