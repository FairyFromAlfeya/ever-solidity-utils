pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityGas.sol";
import "../../../contracts/libraries/UtilityFlag.sol";

import "../../../contracts/tip3/interfaces/ITokenRoot.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";

contract TokenRootExample is Reservable {
    uint32 private static _nonce;
    ITokenRoot private static _root;

    address private _remainingGasRecipient;

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
    {
        _remainingGasRecipient = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;
    }

    function name()
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _root
            .name{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false,
                callback: TokenRootExample.onName
            }();
    }

    function symbol()
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _root
            .symbol{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false,
                callback: TokenRootExample.onSymbol
            }();
    }

    function decimals()
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _root
            .decimals{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false,
                callback: TokenRootExample.onDecimals
            }();
    }

    function totalSupply()
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _root
            .totalSupply{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false,
                callback: TokenRootExample.onTotalSupply
            }();
    }

    function rootOwner()
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _root
            .rootOwner{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false,
                callback: TokenRootExample.onRootOwner
            }();
    }

    function walletOf(address _owner)
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _root
            .walletOf{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false,
                callback: TokenRootExample.onWalletOf
            }(_owner);
    }

    function deployWallet(
        address _owner,
        uint128 _deployWalletValue
    )
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        _root
            .deployWallet{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false,
                callback: TokenRootExample.onDeployWallet
            }(_owner, _deployWalletValue);
    }

    function onName(string _name)
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        console.log(format("Name: {}", _name));
    }

    function onSymbol(string _symbol)
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        console.log(format("Symbol: {}", _symbol));
    }

    function onDecimals(uint8 _decimals)
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        console.log(format("Decimals: {}", _decimals));
    }

    function onTotalSupply(uint128 _totalSupply)
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        console.log(format("Total supply: {}", _totalSupply));
    }

    function onRootOwner(address _rootOwner)
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        console.log(format("Owner: {}", _rootOwner));
    }

    function onWalletOf(address _wallet)
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        console.log(format("Wallet: {}", _wallet));
    }

    function onDeployWallet(address _wallet)
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasRecipient, _remainingGasRecipient)
    {
        console.log(format("Deployed wallet: {}", _wallet));
    }
}
