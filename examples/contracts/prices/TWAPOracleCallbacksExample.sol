pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityFlag.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";

import "../../../contracts/prices/oracle/interfaces/IOnObservationCallback.sol";
import "../../../contracts/prices/oracle/interfaces/IOnRateCallback.sol";
import "../../../contracts/prices/oracle/interfaces/ITWAPOracle.sol";

contract TWAPOracleCallbacksExample is
    IOnRateCallback,
    IOnObservationCallback,
    Reservable
{
    uint32 private static _nonce;
    ITWAPOracle private static _oracle;

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
    {}

    function onRateCallback(
        optional(Rate) _rate,
        uint128[],
        TvmCell _payload
    )
        external
        override
        reserveAndRefund(
            UtilityGas.INITIAL_BALANCE,
            abi.decode(_payload, address),
            abi.decode(_payload, address)
        )
    {
        Rate rate = _rate.get();

        console.log(format("Price 0/1: {}", rate.price0To1));
        console.log(format("Price 1/0: {}", rate.price1To0));
        console.log(format("From timestamp: {}", rate.fromTimestamp));
        console.log(format("To timestamp: {}", rate.toTimestamp));
    }

    function onObservationCallback(
        optional(Observation) _observation,
        TvmCell _payload
    )
        external
        override
        reserveAndRefund(
            UtilityGas.INITIAL_BALANCE,
            abi.decode(_payload, address),
            abi.decode(_payload, address)
        )
    {
        Observation observation = _observation.get();

        console.log(format("Cumulative 0/1: {}", observation.price0To1Cumulative));
        console.log(format("Cumulative 1/0: {}", observation.price1To0Cumulative));
        console.log(format("Timestamp: {}", observation.timestamp));
    }

    function rate(
        uint32 _fromTimestamp,
        uint32 _toTimestamp,
        optional(address) _remainingGasTo
    )
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        _oracle
            .rate{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false
            }(
                _fromTimestamp,
                _toTimestamp,
                address(this),
                abi.encode(remainingGasTo)
            );
    }

    function observation(
        uint32 _timestamp,
        optional(address) _remainingGasTo
    )
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        _oracle
            .observation{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false
            }(
                _timestamp,
                abi.encode(remainingGasTo)
            );
    }
}
