// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const IERC20 = require("@openzeppelin/contracts/build/contracts/IERC20.json");

const LINK_ADDRESS = '0x326C977E6efc84E512bB9C30f76E30c160eD06FB';

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  const WeatherAPIConsumer = await hre.ethers.getContractFactory('WeatherAPIConsumer');
  const weatherAPIConsumer = await WeatherAPIConsumer.deploy();
  await weatherAPIConsumer.deployed();
  console.log(`WeatherAPIConsumer deployed on ${weatherAPIConsumer.address}`);

  const FriendlyBet = await hre.ethers.getContractFactory('FriendlyBet');
  const friendlyBet = await FriendlyBet.deploy(weatherAPIConsumer.address);
  await friendlyBet.deployed();
  console.log(`FriendlyBet deployed on ${friendlyBet.address}`);
  
  const LINK = new hre.ethers.Contract(LINK_ADDRESS, IERC20.abi, hre.ethers.provider);
  const tx = await LINK.connect(deployer).transfer(weatherAPIConsumer.address, hre.ethers.utils.parseUnits("1.00", 18));
  await tx.wait(5);
  console.log("transfered LINK to WeatherAPIConsumer");

  await hre.run("verify:verify", {
    address: weatherAPIConsumer.address,
    constructorArguments: [],
  });
  await hre.run("verify:verify", {
    address: friendlyBet.address,
    constructorArguments: [weatherAPIConsumer.address],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
