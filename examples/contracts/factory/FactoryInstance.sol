pragma ton-solidity >= 0.57.1;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityFlag.sol";
import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/validation/abstract/Validatable.sol";

contract FactoryInstance is Validatable {
    // ID for contract redeploy with another address
    uint32 private static _id;

    // Address of the factory
    address private static _factory;

    constructor(optional(address) _remainingGasTo)
        public
        reserveAndAccept(UtilityGas.INITIAL_BALANCE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Owner from params or default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    function _onUpgrade(TvmCell _data) private {
        // Clear previous fields
        tvm.resetStorage();

        // Unpack data
        (
            uint32 id,
            address factory,
            address remainingGasTo
        ) = abi.decode(_data, (
            uint32,
            address,
            address
        ));

        // Set fields
        _id = id;
        _factory = factory;

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    function check(
        optional(address) _remainingGasTo
    )
        external
        view
        reserve(UtilityGas.INITIAL_BALANCE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Gas recipient from params or default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        // Emit event from child contract
        console.log(format("Instance with ID: {}", _id));

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS,
            bounce: false
        });
    }
}
