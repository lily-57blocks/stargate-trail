const path = require("path");
const fs = require("fs");

function getContractABIs(networkName, contractName) {
  const PROJECT_ROOT = path.resolve(__dirname, "..");
  const DEPLOYMENT_PATH = path.resolve(PROJECT_ROOT, "deployments");

  let folderName = networkName;
  if (networkName === "hardhat") {
    folderName = "localhost";
  }

  const networkFolderName = fs
    .readdirSync(DEPLOYMENT_PATH)
    .filter((f) => f === folderName)[0];
  if (networkFolderName === undefined) {
    throw new Error("missing deployment files for endpoint " + folderName);
  }

  let rtnABIs = {};
  const networkFolderPath = path.resolve(DEPLOYMENT_PATH, folderName);
  const files = fs
    .readdirSync(networkFolderPath)
    .filter((f) => f.includes(".json"));
  files.forEach((file) => {
    const contractName_ = file.split(".")[0];
    if (
      contractName_ == "all" ||
      !contractName ||
      contractName_ == contractName
    ) {
      const filepath = path.resolve(networkFolderPath, file);
      const data = JSON.parse(fs.readFileSync(filepath));
      rtnABIs[contractName] = data.abi;
    }
  });

  return rtnABIs;
}

module.exports = {
  getContractABIs,
};
