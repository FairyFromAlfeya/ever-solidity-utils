pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityGas.sol";
import "../../../contracts/libraries/UtilityFlag.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";

contract ReservableExample is Reservable {
    uint32 private static _nonce;

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
    {}

    function reserveAndRefundGas(optional(address) _remainingGasTo)
        external
        pure
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
    {
        console.log(format("Message gas: {}", msg.value));
    }

    function reserveGas(optional(address) _remainingGasTo)
        external
        pure
        reserve(UtilityGas.INITIAL_BALANCE)
    {
        console.log(format("Message gas: {}", msg.value));

        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        remainingGasTo.transfer({
            value: 0,
            flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS,
            bounce: false
        });
    }
}
