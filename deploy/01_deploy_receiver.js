const hre = require("hardhat");
const { config } = require("../scripts/config.js");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const network = hre.network.name;
  console.log("Deploying to network: ", network);

  if (network !== "polygonMumbai") {
    console.log("Skipping Receiver deployment on non-polygonMumbai network");
    return;
  }
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const { router } = config[network];

  await deploy("Receiver", {
    from: deployer,
    args: [router],
    log: true,
  });
};
module.exports.tags = ["Receiver"];
