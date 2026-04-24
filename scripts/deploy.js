const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying NumberGuessV2...");
  const Contract = await ethers.getContractFactory("NumberGuessV2");
  const contract = await Contract.deploy();
  await contract.waitForDeployment();
  console.log("NumberGuessV2 deployed to:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
