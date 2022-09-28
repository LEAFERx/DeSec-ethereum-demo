# CS294 Smart Contract Demo

## Install

```
npm install
```

Create `.env` according to `.env.example` (Deployer is also party one).

Get tokens from faucet.

## Deploy

```
npx hardhat --network goerli run scripts/deploy.js
```

## Bet

```
npx hardhat --network goerli bet --address <bet contract address> --party-idx <1 or 2>
```