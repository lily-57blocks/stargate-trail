// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IStargateRouter.sol";

error InsufficientBalance();
error InvalidCaller();
error InvalidParam();
error SettingError();

contract USDCBridgeTokenHelperWithPayload is Ownable {
    uint256 public constant SRC_POOL_ID = 1; // USDC pool

    IStargateRouter public immutable router;
    IERC20 public immutable token;

    uint256 public slippage = 50; // 0.5%
    address public dstContract;

    event StartBridgeToken(
        address indexed sender,
        address indexed receiver,
        uint16 destChainId,
        uint256 destPoolId,
        uint256 amount
    );
    event UpdateSlipperage(uint256 slipperage);
    event UpdateDstContract(address dstContract);

    constructor(address router_, address token_) Ownable() {
        router = IStargateRouter(router_);
        token = IERC20(token_);
    }

    function updateSlipperage(uint256 slippage_) external onlyOwner {
        slippage = slippage_;
        emit UpdateSlipperage(slippage);
    }

    function updateDstContract(address dstContract_) external onlyOwner {
        dstContract = dstContract_;
        emit UpdateDstContract(dstContract);
    }

    function bridgeTokenAndExecute(
        uint16 destChainId,
        uint256 destPoolId,
        uint256 amount,
        address receiver
    ) external payable {
        if (dstContract == address(0)) revert SettingError();

        if (amount == 0) revert InvalidParam();

        token.transferFrom(msg.sender, address(this), amount);

        token.approve(address(router), amount);

        bytes memory data = abi.encode(receiver);

        uint256 amountOutMin = (amount * (10000 - slippage)) / 10000;
        bytes memory adr = abi.encodePacked(dstContract);
        router.swap{value: msg.value}(
            destChainId,
            SRC_POOL_ID,
            destPoolId,
            payable(msg.sender), // refund Address
            amount,
            amountOutMin,
            IStargateRouter.lzTxObj(200000, 0, "0x"), // remember to set the first param on lzTxObj if the receiver is contract
            adr, // the address to send the tokens to on the destination
            data
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
        bytes memory adr = abi.encodePacked(dstContract);
        bytes memory data = abi.encode(receiver);
        (fee, ) = router.quoteLayerZeroFee(
            destChainId,
            1, // functionType: 1 = swap
            adr,
            data,
            IStargateRouter.lzTxObj(200000, 0, adr)
        );
    }
}
