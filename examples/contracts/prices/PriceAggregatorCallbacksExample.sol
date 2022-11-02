pragma ever-solidity >= 0.63.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityFlag.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";

import "../../../contracts/prices/aggregator/interfaces/IOnCanceledPriceCallback.sol";
import "../../../contracts/prices/aggregator/interfaces/IOnSuccessPriceCallback.sol";

contract PriceAggregatorCallbacksExample is
    IOnSuccessPriceCallback,
    IOnCanceledPriceCallback,
    Reservable
{
    uint32 private static _nonce;

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
    {}

    function onSuccessPriceCallback(
        mapping(address => uint) _prices,
        mapping(address => int16) _scales,
        uint64 _timestamp,
        address _sender,
        TvmCell _payload
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _sender, _sender)
    {
        for ((address token, uint price) : _prices) {
            console.log(format("Price/Scale: {} - {}/{}", token, price, _scales[token]));
        }

        console.log(format("Timestamp: {}", _timestamp));
        console.log(format("Sender: {}", _sender));
    }

    function onCanceledPriceCallback(
        mapping(address => uint) _prices,
        mapping(address => int16) _scales,
        address[] _failed,
        uint64 _timestamp,
        address _sender,
        TvmCell _payload
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _sender, _sender)
    {
        for ((address token, uint price) : _prices) {
            console.log(format("Price/Scale: {} - {}/{}", token, price, _scales[token]));
        }

        for (address token : _failed) {
            console.log(format("Failed: {}", token));
        }

        console.log(format("Timestamp: {}", _timestamp));
        console.log(format("Sender: {}", _sender));
    }
}
