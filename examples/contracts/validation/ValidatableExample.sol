pragma ton-solidity >= 0.57.1;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/validation/abstract/Validatable.sol";

import "../../../contracts/libraries/MsgFlag.sol";
import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

contract ValidatableExample is Validatable {
    // Random number for contract redeploy with another address
    uint32 private static _nonce;

    constructor(optional(address) _remainingGasTo)
        public
        reserveAndAccept(UtilityGas.INITIAL_BALANCE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Gas recipient from params or default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    function getValidTvmCell(uint32 _id)
        external
        pure
        responsible
        returns (TvmCell)
    {
        return {
            value: 0,
            flag: MsgFlag.REMAINING_GAS,
            bounce: false
        } abi.encode(_id);
    }

    function isValidAddress(
        address _a,
        optional(address) _remainingGasTo
    )
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
        validAddress(_a, UtilityErrors.INVALID_ADDRESS)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        console.log(format("Address is valid: {}", _nonce));

        // Gas recipient from params or default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    function isValidTvmCell(
        TvmCell _a,
        optional(address) _remainingGasTo
    )
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
        validTvmCell(_a, UtilityErrors.INVALID_CODE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        console.log(format("TvmCell is valid: {}", _nonce));

        // Gas recipient from params or default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }
}
