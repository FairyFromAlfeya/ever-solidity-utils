pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityGas.sol";
import "../../../contracts/libraries/UtilityFlag.sol";

import "../../../contracts/tip3/interfaces/ITokenWallet.sol";
import "../../../contracts/tip3/interfaces/ITokenRoot.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";

contract TokenWalletExample is Reservable {
    uint32 private static _nonce;
    ITokenWallet private static _wallet;

    ITokenWallet private _ownWallet;
    address private _remainingGasRecipient;

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
    {
        _remainingGasRecipient = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        _wallet
            .root{
                value: 0.5 ever,
                flag: UtilityFlag.SENDER_PAYS_FEES,
                bounce: false,
                callback: TokenWalletExample.onOwnRoot
            }();
    }

    function onOwnRoot(address _root)
        external
        pure
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        ITokenRoot(_root)
            .walletOf{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false,
                callback: TokenWalletExample.onOwnWalletOf
            }(address(this));
    }

    function onOwnWalletOf(address _walletAddress)
        external
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        _ownWallet = ITokenWallet(_walletAddress);
    }

    function root()
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _wallet
            .root{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false,
                callback: TokenWalletExample.onRoot
            }();
    }

    function balance()
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _wallet
            .balance{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false,
                callback: TokenWalletExample.onBalance
            }();
    }

    function owner()
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _wallet
            .owner{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false,
                callback: TokenWalletExample.onOwner
            }();
    }

    function transfer(
        uint128 _amount,
        address _recipient,
        uint128 _deployWalletValue,
        address _remainingGasTo,
        bool _notify,
        TvmCell _payload
    )
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _ownWallet
            .transfer{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false
            }(
                _amount,
                _recipient,
                _deployWalletValue,
                _remainingGasTo,
                _notify,
                _payload
            );
    }

    function transferToWallet(
        uint128 _amount,
        address _recipientWallet,
        address _remainingGasTo,
        bool _notify,
        TvmCell _payload
    )
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _ownWallet
            .transferToWallet{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false
            }(
                _amount,
                _recipientWallet,
                _remainingGasTo,
                _notify,
                _payload
            );
    }

    function onRoot(address _root)
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        console.log(format("Root: {}", _root));
    }

    function onBalance(uint128 _balance)
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        console.log(format("Balance: {}", _balance));
    }

    function onOwner(address _owner)
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        console.log(format("Owner: {}", _owner));
    }
}
