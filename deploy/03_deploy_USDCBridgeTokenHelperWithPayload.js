const hre = require("hardhat");
const { config } = require("../scripts/config.js");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const network = hre.network.name;
  console.log("Deploying to network: ", network);

  if (network !== "goerli") {
    console.log(
      "Skipping USDCBridgeTokenHelperWithPayload deployment on non-goerli network"
    );
    return;
  }
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const { usdc, router } = config[network];

  await deploy("USDCBridgeTokenHelperWithPayload", {
    from: deployer,
    args: [router, usdc],
    log: true,
  });
};
module.exports.tags = ["USDCBridgeTokenHelperWithPayload"];
