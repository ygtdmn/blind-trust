# Blind Trust

Blind Trust is an on-chain experiment on trust between artist and collector.

# Deployed Contracts

| Chain    | Contract           | Address                                    |
| -------- | ------------------ | ------------------------------------------ |
| Ethereum | BlindTrust         | 0xA467cf4c595880F4b44Bc67356c680cfEE6a0895 |
| Ethereum | BlindTrustRenderer | 0x987B6d43C7Fcc994D31F882C3742c01ba3f854A6 |
| Ethereum | Ephemera           | 0xCb337152b6181683010D07e3f00e7508cd348BC7 |

# How to Deploy

`bun install`

`forge script script/Deploy.s.sol:Deploy --rpc-url mainnet --broadcast --verify`
