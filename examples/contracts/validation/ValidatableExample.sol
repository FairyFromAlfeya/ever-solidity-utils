pragma ever-solidity >= 0.63.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";

import "../../../contracts/validation/abstract/Validatable.sol";

import "../../../contracts/libraries/UtilityFlag.sol";
import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

contract ValidatableExample is Reservable, Validatable {
    uint32 private static _nonce;

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
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
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
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
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        validTvmCell(_a, UtilityErrors.INVALID_CODE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        console.log(format("TvmCell is valid: {}", _nonce));
    }
}
