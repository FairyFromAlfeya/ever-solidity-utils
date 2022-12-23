pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityGas.sol";
import "../../../contracts/libraries/UtilityFlag.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";
import "../../../contracts/reservation/abstract/TargetBalance.sol";

contract ReservableExample is Reservable, TargetBalance {
    uint32 private static _nonce;

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
    {}

    function reserveAndRefundGas(optional(address) _remainingGasTo)
        external
        view
        reserveAndRefund(_getTargetBalanceInternal(), _remainingGasTo, msg.sender)
    {
        console.log(format("Message gas: {}", msg.value));
    }

    function reserveGas(optional(address) _remainingGasTo)
        external
        view
        reserve(_getTargetBalanceInternal())
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
