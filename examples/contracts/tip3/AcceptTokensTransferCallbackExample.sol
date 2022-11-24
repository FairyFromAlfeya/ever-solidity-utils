pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";

import "../../../contracts/tip3/interfaces/IAcceptTokensTransferCallback.sol";
import "../../../contracts/tip3/interfaces/ITokenRoot.sol";

contract AcceptTokensTransferCallbackExample is
    IAcceptTokensTransferCallback,
    Reservable
{
    uint32 private static _nonce;

    address private _wallet;
    address private _remainingGasRecipient;

    modifier onlyWallet() {
        require(_wallet.value != 0 && msg.sender == _wallet, 1234);
        _;
    }

    constructor(
        address _root,
        optional(address) _remainingGasTo
    )
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
    {
        _remainingGasRecipient = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        ITokenRoot(_root)
            .walletOf{
                value: 0.5 ever,
                flag: UtilityFlag.SENDER_PAYS_FEES,
                bounce: false,
                callback: AcceptTokensTransferCallbackExample.onWalletOf
            }(address(this));
    }

    function onWalletOf(address _walletAddress)
        external
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        _wallet = _walletAddress;
    }

    function onAcceptTokensTransfer(
        address _tokenRoot,
        uint128 _amount,
        address _sender,
        address _senderWallet,
        address _remainingGasTo,
        TvmCell
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, _remainingGasTo)
        onlyWallet
    {
        console.log(format("TokenRoot: {}", _tokenRoot));
        console.log(format("Amount: {}", _amount));
        console.log(format("Sender: {}", _sender));
        console.log(format("Sender wallet: {}", _senderWallet));
    }
}
