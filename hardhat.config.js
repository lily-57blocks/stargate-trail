require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    goerli: {
      url: `${process.env.GOERLI_RPC_URL}`,
      accounts: [
        `${process.env.DEPLOYER_PRIVATE_KEY}`,
        `${process.env.TESTER_PRIVATE_KEY}`,
      ],
    },
    polygonMumbai: {
      url: `${process.env.POLYGON_MUMBAI_RPC_URL}`,
      accounts: [
        `${process.env.DEPLOYER_PRIVATE_KEY}`,
        `${process.env.TESTER_PRIVATE_KEY}`,
      ],
    },
  },
  etherscan: {
    apiKey: {
      goerli: `${process.env.ETHERSCAN_API_KEY}`,
      polygonMumbai: `${process.env.POL_ETHERSCAN_API_KEY}`,
    },
  },
  namedAccounts: {
    deployer: { default: 0 },
    tester: { default: 1 },
  },
};
