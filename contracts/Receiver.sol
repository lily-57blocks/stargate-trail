// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IStargateReceiver.sol";

contract Receiver is IStargateReceiver {
    address public immutable stargateRouter;

    event ReceivedOnDestination(address token, uint amountLD, address receiver);

    constructor(address _stargateRouter) {
        stargateRouter = _stargateRouter;
    }

    // called by the StargateRouter on the destination chain
    function sgReceive(
        uint16 _chainId, // the remote chainId sending the tokens
        bytes memory _srcAddress, // the remote Bridge address not the real sender
        uint _nonce,
        address _token, // the token contract on the local chain
        uint amountLD,
        bytes memory _payload
    ) external override {
        require(
            msg.sender == address(stargateRouter),
            "only stargate router can call sgReceive!"
        );
        address _toAddr = abi.decode(_payload, (address));
        IERC20(_token).transfer(_toAddr, amountLD);
        emit ReceivedOnDestination(_token, amountLD, _toAddr);
    }
}
