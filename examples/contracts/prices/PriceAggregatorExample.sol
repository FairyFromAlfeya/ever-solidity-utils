pragma ever-solidity >= 0.63.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/factory/abstract/Factory.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityFlag.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";

import "../../../contracts/prices/aggregator/interfaces/IPriceAggregatorInstance.sol";
import "../../../contracts/prices/aggregator/interfaces/IOnCanceledPriceCallback.sol";
import "../../../contracts/prices/aggregator/interfaces/IOnSuccessPriceCallback.sol";

contract PriceAggregatorExample is
    IPriceAggregatorInstance,
    Reservable,
    Validatable
{
    uint32 private static _nonce;

    mapping(address => uint) private _prices;
    mapping(address => int16) private _scales;

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
    {}

    function setPriceAndScale(
        address _token,
        uint _price,
        int16 _scale,
        optional(address) _remainingGasTo
    )
        external
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
    {
        _prices[_token] = _price;
        _scales[_token] = _scale;
    }

    function getPrices(
        address[] _tokens,
        address _callbackRecipient,
        bool _proxy,
        address _remainingGasTo,
        TvmCell _payload
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, _remainingGasTo)
    {
        mapping(address => uint) prices;
        mapping(address => int16) scales;
        address[] failed;

        for (address token : _tokens) {
            if (_prices.exists(token)) {
                prices[token] = _prices[token];
                scales[token] = _scales[token];
            } else {
                failed.push(token);
            }
        }

        if (failed.length == 0) {
            IOnSuccessPriceCallback(_callbackRecipient)
                .onSuccessPriceCallback{
                    value: 0,
                    flag: UtilityFlag.ALL_NOT_RESERVED,
                    bounce: false
                }(
                    prices,
                    scales,
                    now,
                    msg.sender,
                    _payload
                );
        } else {
            IOnCanceledPriceCallback(_callbackRecipient)
                .onCanceledPriceCallback{
                    value: 0,
                    flag: UtilityFlag.ALL_NOT_RESERVED,
                    bounce: false
                }(
                    prices,
                    scales,
                    failed,
                    now,
                    msg.sender,
                    _payload
                );
        }
    }
}
