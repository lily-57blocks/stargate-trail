# Stargate Token Bridge Tutorial

This project demonstrates using stargate to bridge USDC on TestNet (from goerli to polygon mumbai).
More details you can go through the official document [how-to-swap](https://stargateprotocol.gitbook.io/stargate/developers/how-to-swap)

USDCBridgeTokenHelper.sol: respond to bridge usdc

USDCBridgeTokenHelperWithPayload.sol: respond to bridge usdc but the receiver on destination to receive the token is in payload

Receiver.sol: it's the receiver contract that USDCBridgeTokenHelper bridge token to. it will encode payload and transfer the token to the real receiver

The cross chain transaction need some native token as relayer fee. you can get more from [cross-chain-swap-fee](https://stargateprotocol.gitbook.io/stargate/developers/cross-chain-swap-fee). in this guide you can get the fee by view function `calculateRelayerFee`. to ensure the success of the transaction, you'd better add some buffer.

## Guide

0. Set up the environments with yarn
   `yarn install`

1. Update the settings in .env.sample file. Change the .env.example filename to .env

   - DEPLOYER_PRIVATE_KEY to deploy smart contracts
   - TESTER_PRIVATE_KEY to send transaction to call smart contracts
   - GOERLI_RPC_URL and POLYGON_MUMBAI_RPC_URL the rpc urls on goerli or mumbai
   - ETHERSCAN_API_KEY and POL_ETHERSCAN_API_KEY to auto verify smart contract

2. Deploy the example contracts on goerli testnet and polygon testnet. Make sure the deployer have gas tokens on both chains

   - `npx hardhat --network polygonMumbai deploy`
   - `npx hardhat --network goerli deploy`

3. Test the flow by running the below command. (You can change the param in function to change the bridge token amount)

   - `npx hardhat run --network goerli scripts/bridgeToken.js`
   - `npx hardhat run --network goerli scripts/bridgeTokenWithPayload.js`

4. After send bridge token transaction, you can use [layerzeroscan](https://testnet.layerzeroscan.com/) to check the status of
   bridge token transaction. Just search up the transaction hash from the execution transaction.
