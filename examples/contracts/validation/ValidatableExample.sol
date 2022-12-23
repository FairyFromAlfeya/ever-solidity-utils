pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";
import "../../../contracts/reservation/abstract/TargetBalance.sol";

import "../../../contracts/validation/abstract/Validatable.sol";

import "../../../contracts/libraries/UtilityFlag.sol";
import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

contract ValidatableExample is
    Reservable,
    Validatable,
    TargetBalance
{
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
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {}

    function getValidTvmCell(uint32 _id)
        external
        pure
        responsible
        returns (TvmCell)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } abi.encode(_id);
    }

    function isValidAddress(
        address _a,
        optional(address) _remainingGasTo
    )
        external
        view
        reserveAndRefund(_getTargetBalanceInternal(), _remainingGasTo, msg.sender)
        validAddress(_a, UtilityErrors.INVALID_ADDRESS)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        console.log(format("Address is valid: {}", _nonce));
    }

    function isValidTvmCell(
        TvmCell _a,
        optional(address) _remainingGasTo
    )
        external
        view
        reserveAndRefund(_getTargetBalanceInternal(), _remainingGasTo, msg.sender)
        validTvmCell(_a, UtilityErrors.INVALID_CODE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        console.log(format("TvmCell is valid: {}", _nonce));
    }
}
