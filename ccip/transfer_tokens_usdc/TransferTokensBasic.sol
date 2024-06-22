// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees);
// 6 decimales
// 1 USDC = 100000
contract TransferTokensBasic  {
    using SafeERC20 for IERC20;

    IERC20 private s_linkToken;
    IRouterClient private s_router;

    enum FeesWillBePaidWith { Native, LINK }

    constructor(address _router, address _link)  {
        s_linkToken = IERC20(_link);
        s_router = IRouterClient(_router);
    }

    function sendMessagePayLINK(
        uint64 _destinationChainSelector,
        address _receiver,
        string calldata _text,
        address _token,
        uint256 _amount,
        FeesWillBePaidWith _fees
    )
        external                        
        returns (bytes32 messageId)
    {
        address feesWillBePaidWith = _fees == FeesWillBePaidWith.LINK ? address(s_linkToken) : address(0);

        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _receiver,
            _text,
            _token,
            _amount,
            feesWillBePaidWith
        );

        uint256 fees = s_router.getFee(_destinationChainSelector, evm2AnyMessage);

        if(_fees == FeesWillBePaidWith.LINK){
            if (fees > s_linkToken.balanceOf(address(this)))
                revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);

            s_linkToken.approve(address(s_router), fees);                    
        }else{
            if (fees > address(this).balance)
                revert NotEnoughBalance(address(this).balance, fees);                    
        }

        IERC20(_token).approve(address(s_router), _amount); 
       
        messageId = s_router.ccipSend(_destinationChainSelector, evm2AnyMessage);        
        return messageId;
    }

    function _buildCCIPMessage(
        address _receiver, // Quién recibirá los tokens, si es contrato debe implementar Receiver
        string calldata _text, // Texto que enviaremos, si es un EOA solo recibirá tokens
        address _token, // El address del token que se va a transferir
        uint256 _amount, // El monto de tokens que se va a transferir
        address _feeTokenAddress // 
    ) private pure returns (Client.EVM2AnyMessage memory) {
        // Set the token amounts
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({
            token: _token,
            amount: _amount
        });
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        return
            Client.EVM2AnyMessage({
                receiver: abi.encode(_receiver), // ABI-encoded receiver address
                data: abi.encode(_text), // ABI-encoded string
                tokenAmounts: tokenAmounts, // The amount and type of token being transferred
                extraArgs: Client._argsToBytes(
                    // Additional arguments, setting gas limit
                    Client.EVMExtraArgsV1({gasLimit: 200_000})
                ),
                // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
                feeToken: _feeTokenAddress
            });
    }

    receive() external payable {}
}
