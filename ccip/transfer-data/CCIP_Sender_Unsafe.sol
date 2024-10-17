// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";

contract Messenger {
    IERC20 private s_linkToken;
    IRouterClient private s_router;

    constructor(address _router, address _link) {
        s_linkToken = IERC20(_link);
        s_router = IRouterClient(_router);
    }

    function send(
        uint64 _destinationChainSelector,
        address _receiver,
        string calldata _text
    ) external {
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encode(_text),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: address(s_linkToken)
        });

        s_linkToken.approve(address(s_router), 1e18 ether);
        s_router.ccipSend(_destinationChainSelector, evm2AnyMessage);
    }
}
