// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

const log = require('fancy-log');

module.exports = async function main({address, partyIdx}, hre) {
  const signers = await hre.ethers.getSigners();
  const party = signers[partyIdx-1];
  const ourAddress = party.address;

  const friendlyBet = await hre.ethers.getContractAt('FriendlyBet', address, party);

  friendlyBet.on('BetJoined', (party, partyIdx) => {
    var msg = `${party} just bet on the contract. `
    if (party == ourAddress) {
        msg += "It's us! Good luck!"
    } else {
        msg += "It's another one!"
    }
    log(msg);
  });
  friendlyBet.on('BetEstablished', (party1, party2, requestId) => {
    log(`${party1} and ${party2} established a bet.`);
  });
  const executed = new Promise((resolve) => friendlyBet.on('BetExecuted', (winner, temperature) => {
    var msg = `${winner} wins because temperature is ${temperature}. `;
    if (winner == ourAddress) {
        msg += "We win!"
    } else {
        msg += "We lose.."
    }
    log(msg);
    resolve();
  }));

  const tx = await friendlyBet.joinBet({ value: hre.ethers.utils.parseEther("0.005", "ether")});
  log(`Bet join request sent in transaction ${tx.hash}`);

  await tx.wait();
  await executed;
}
