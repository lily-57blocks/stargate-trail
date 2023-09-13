// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IStargateRouter.sol";

error InsufficientBalance();
error InvalidCaller();
error InvalidParam();

contract USDCBridgeTokenHelper is Ownable {
    // Stargate use Pool to manage token's liquidity. you can find the all pools
    // in https://stargateprotocol.gitbook.io/stargate/developers/pool-ids
    uint256 public constant SRC_POOL_ID = 1; // USDC pool

    // Stargate use Router to manage cross-chain transfer. you can find the all routers in here
    // mainnet: https://stargateprotocol.gitbook.io/stargate/developers/contract-addresses/mainnet
    // testnet: https://stargateprotocol.gitbook.io/stargate/developers/contract-addresses/testnet
    IStargateRouter public immutable router;
    IERC20 public immutable token;

    uint256 public slippage = 50; // 0.5%

    event StartBridgeToken(
        address indexed sender,
        address indexed receiver,
        uint16 destChainId,
        uint256 destPoolId,
        uint256 amount
    );
    event UpdateSlipperage(uint256 slipperage);

    constructor(address router_, address token_) Ownable() {
        router = IStargateRouter(router_);
        token = IERC20(token_);
    }

    function updateSlipperage(uint256 slippage_) external onlyOwner {
        slippage = slippage_;
        emit UpdateSlipperage(slippage);
    }

    function bridgeToken(
        uint16 destChainId,
        uint256 destPoolId,
        uint256 amount,
        address receiver
    ) external payable {
        if (amount == 0) revert InvalidParam();

        token.transferFrom(msg.sender, address(this), amount);

        token.approve(address(router), amount);

        uint256 amountOutMin = (amount * (10000 - slippage)) / 10000;
        bytes memory adr = abi.encodePacked(receiver);
        router.swap{value: msg.value}(
            destChainId, // destination chain id
            SRC_POOL_ID,
            destPoolId,
            payable(receiver), // refund Address
            amount,
            amountOutMin,
            IStargateRouter.lzTxObj(0, 0, "0x"),
            adr, // the address to send the tokens to on the destination
            "0x" // payload
        );
        emit StartBridgeToken(
            msg.sender,
            receiver,
            destChainId,
            destPoolId,
            amount
        );
    }

    function calculateRelayerFee(
        uint16 destChainId,
        address receiver
    ) external view returns (uint256 fee) {
        bytes memory adr = abi.encodePacked(receiver);
        (fee, ) = router.quoteLayerZeroFee(
            destChainId,
            1, // functionType: 1 = swap
            adr,
            "0x",
            IStargateRouter.lzTxObj(0, 0, adr)
        );
    }
}
