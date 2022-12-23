pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/libraries/UtilityFlag.sol";
import "../../../contracts/libraries/UtilityGas.sol";
import "../../../contracts/libraries/FixedPoint128.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";
import "../../../contracts/reservation/abstract/TargetBalance.sol";

import "../../../contracts/prices/oracle/interfaces/ITWAPOracle.sol";
import "../../../contracts/prices/oracle/interfaces/IOnObservationCallback.sol";
import "../../../contracts/prices/oracle/interfaces/IOnRateCallback.sol";

contract PriceAggregatorExample is
    ITWAPOracle,
    Reservable,
    TargetBalance
{
    uint32 private static _nonce;

    OracleOptions private _options;
    mapping(uint32 => Observation) private _observations;

    function _getTargetBalanceInternal()
        internal
        view
        override
        returns (uint128)
    {
        return UtilityGas.INITIAL_BALANCE;
    }

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(_getTargetBalanceInternal(), _remainingGasTo, msg.sender)
    {
        Observation observation = Observation({
            timestamp: now,
            price0To1Cumulative: 0,
            price1To0Cumulative: 0
        });

        emit OracleInitialized(observation);
    }

    function setObservation(
        Observation _observation,
        optional(address) _remainingGasTo
    )
        external
        reserveAndRefund(_getTargetBalanceInternal(), _remainingGasTo, msg.sender)
    {
        _observations[_observation.timestamp] = _observation;

        emit OracleUpdated(_observation);
    }

    function getObservation(uint32 _timestamp)
        external
        view
        override
        responsible
        returns (optional(Observation))
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } _observations.fetch(_timestamp);
    }

    function observation(
        uint32 _timestamp,
        address _callbackTo,
        TvmCell _payload
    )
        external
        view
        override
        reserve(_getTargetBalanceInternal())
    {
        IOnObservationCallback(_callbackTo)
            .onObservationCallback{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false
            }(
                _observations.fetch(_timestamp),
                msg.sender,
                _payload
            );
    }

    function getRate(
        uint32 _fromTimestamp,
        uint32 _toTimestamp
    )
        external
        view
        override
        responsible
        returns (optional(Rate), uint128[])
    {
        optional(Rate) rateOpt = _calculateRate(
            _fromTimestamp,
            _toTimestamp
        );
        uint128[] reserves;

        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } (rateOpt, reserves);
    }

    function rate(
        uint32 _fromTimestamp,
        uint32 _toTimestamp,
        address _callbackTo,
        TvmCell _payload
    )
        external
        view
        override
        reserve(_getTargetBalanceInternal())
    {
        uint128[] reserves;

        IOnRateCallback(_callbackTo)
            .onRateCallback{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false
            }(
                _calculateRate(_fromTimestamp, _toTimestamp),
                reserves,
                msg.sender,
                _payload
            );
    }

    function getExpectedAmountByTWAP(
        uint128 _amount,
        address,
        uint32 _fromTimestamp,
        uint32 _toTimestamp
    )
        external
        view
        override
        responsible
        returns (uint128)
    {
        return {
            value: 0,
            bounce: false,
            flag: UtilityFlag.REMAINING_GAS
        } FixedPoint128.calculateExpectedAmountByRate(
            _amount,
            _calculateRate(_fromTimestamp, _toTimestamp).get().price0To1
        );
    }

    function setOracleOptions(
        OracleOptions _newOptions,
        address _remainingGasTo
    )
        external
        override
        reserveAndRefund(_getTargetBalanceInternal(), _remainingGasTo, _remainingGasTo)
    {
        _options = _newOptions;

        emit OracleOptionsUpdated(_newOptions);
    }

    function getOracleOptions()
        external
        view
        override
        responsible
        returns (OracleOptions)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } _options;
    }

    function removeLastNPoints(
        uint16 _count,
        address _remainingGasTo
    )
        external
        override
        reserveAndRefund(_getTargetBalanceInternal(), _remainingGasTo, _remainingGasTo)
    {
        for (uint16 i = 0; i < _count; i++) {
            _observations.delMin();
        }
    }

    function _calculateRate(
        uint32 _fromTimestamp,
        uint32 _toTimestamp
    )
        private
        view
        returns (optional(Rate))
    {
        optional(Observation) fromObservationOpt = _observations.fetch(_fromTimestamp);
        optional(Observation) toObservationOpt = _observations.fetch(_toTimestamp);
        optional(Rate) rateOpt;

        if (fromObservationOpt.hasValue() && toObservationOpt.hasValue()) {
            uint32 period = _toTimestamp - _fromTimestamp;

            Observation fromObservation = fromObservationOpt.get();
            Observation toObservation = toObservationOpt.get();

            rateOpt = Rate({
                price0To1: (toObservation.price0To1Cumulative - fromObservation.price0To1Cumulative) / period,
                price1To0: (toObservation.price1To0Cumulative - fromObservation.price1To0Cumulative) / period,
                fromTimestamp: _fromTimestamp,
                toTimestamp: _toTimestamp
            });
        }

        return rateOpt;
    }
}
