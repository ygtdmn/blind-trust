// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { BaseScript } from "./Base.s.sol";
import { BlindTrustRenderer } from "../src/BlindTrustRenderer.sol";
import { BlindTrust } from "../src/BlindTrust.sol";

contract Deploy is BaseScript {
    function run() public broadcast returns (BlindTrustRenderer renderer, BlindTrust blindTrust) {
        address ephemera = address(0xCb337152b6181683010D07e3f00e7508cd348BC7); // mainnet
        // address ephemera = address(0xBF6b69aF9a0f707A9004E85D2ce371Ceb665237B); // sepolia
        string memory metadata =
            unicode"\"name\": \"Blind Trust\",\"description\": \"Blind Trust is an on-chain experiment on trust between the artist and the collector.\"";
        renderer = new BlindTrustRenderer(metadata, ephemera, address(0x077be47506ABa13F54b20850fd47d1Cea69d84A5));
        blindTrust = new BlindTrust(address(renderer), address(ephemera));
        renderer.setBlindTrust(address(blindTrust));
    }
}
