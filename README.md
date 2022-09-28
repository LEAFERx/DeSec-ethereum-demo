# CS294 Smart Contract Demo

## Install

```
npm install
```

Create `.env` according to `.env.example` (Deployer is also party1).

Get tokens from [faucet](https://faucets.chain.link) using Metamask (for Goerli testnet).

Get API keys from [Alchemy](https://www.alchemy.com) and [Etherscan](https://etherscan.io).

## Deploy

```
npx hardhat --network goerli run scripts/deploy.js
```

## Bet

```
npx hardhat --network goerli bet --address <bet contract address> --party-idx <1 or 2>
```