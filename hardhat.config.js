require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("@nomiclabs/hardhat-etherscan");
const bet = require("./scripts/bet");

task("bet", "bet on the contract")
  .addParam("address", "The FriendlyBet contract address")
  .addParam("partyIdx", "Either 1 or 2")
  .setAction(bet);


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY,
        process.env.PARTY2_PRIVATE_KEY,
      ],
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: process.env.ETHERSCAN_API_KEY,
  }
};
