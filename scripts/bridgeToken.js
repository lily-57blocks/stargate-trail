const { getNamedAccounts } = require("hardhat");
const { ethers } = require("hardhat");
const { config } = require("./config.js");
const BigNumber = require("bignumber.js");
const { getContractAddresses } = require("./getContractAddresses.js");

async function approve(user, bridger, amount) {
  const network = hre.network.name;
  if (network !== "goerli") {
    console.log("Skipping approve on non-goerli network");
    return;
  }
  console.log(`Approving token on ${network}`);
  const { usdc } = config[network];
  const usdcContract = await hre.ethers.getContractAt("IERC20", usdc);
  const balance = await usdcContract.balanceOf(user.address);
  console.log(`balance: ${balance}`);
  if (BigNumber(balance).isLessThan(BigNumber(amount))) {
    console.log(`insufficient balance: ${balance}, approve: ${amount}`);
    return;
  }
  const tx = await usdcContract.connect(user).approve(bridger, amount);
  console.log(`approve tx: ${tx.hash}, amount: ${amount} to ${bridger}`);
  await tx.wait();
}

async function bridgeToken(amount) {
  const network = hre.network.name;
  if (network !== "goerli") {
    console.log("Skipping bridgeToken on non-goerli network");
    return;
  }
  const destChain = "polygonMumbai";
  console.log(`bridge token from ${network} to ${destChain}`);
  const contractName = "USDCBridgeTokenHelper";
  const usdcBridgeTokenHelperAddress = getContractAddresses(
    network,
    contractName
  )[contractName];
  console.log(`usdcBridgeTokenHelperAddress: ${usdcBridgeTokenHelperAddress}`);
  let usdcBridgeTokenHelper = await hre.ethers.getContractAt(
    contractName,
    usdcBridgeTokenHelperAddress
  );
  const { tester: receiver } = await getNamedAccounts();
  console.log(`tester: ${receiver}`);
  const sender = await hre.ethers.getSigner(receiver);

  amount = ethers.parseUnits(amount, 6);

  await approve(sender, usdcBridgeTokenHelperAddress, amount);

  const { chainId } = config[destChain];
  let relayerFee = await usdcBridgeTokenHelper.calculateRelayerFee(
    chainId,
    receiver
  );
  console.log(`relayerFee: ${relayerFee}`);
  relayerFee = BigNumber(relayerFee).times(1.02).toFixed(0);
  console.log(`final relayerFee: ${relayerFee}`);
  let tx = await usdcBridgeTokenHelper
    .connect(sender)
    .bridgeToken(chainId, 1, amount, receiver, { value: relayerFee });
  console.log(`bridgeToken tx: ${tx.hash}`);
}

bridgeToken("1").catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
