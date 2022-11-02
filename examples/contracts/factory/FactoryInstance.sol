pragma ever-solidity >= 0.63.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/validation/abstract/Validatable.sol";
import "../../../contracts/reservation/abstract/Reservable.sol";

contract FactoryInstance is Reservable, Validatable {
    // ID for contract redeploy with another address
    uint32 private static _id;

    // Address of the factory
    address private static _factory;

    event IdChanged(
        uint32 current,
        uint32 previous
    );

    event FactoryChanged(
        address current,
        address previous
    );

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {}

    function onCodeUpgrade(TvmCell _data) private {
        // Clear previous fields
        tvm.resetStorage();

        // Unpack data
        (
            uint32 id,
            address factory
        ) = abi.decode(_data, (
            uint32,
            address
        ));

        // Set fields
        _setIdInternal(id);
        _setFactoryInternal(factory);
    }

    function check(
        optional(address) _remainingGasTo
    )
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Emit event from child contract
        console.log(format("Instance with ID: {}", _getIdInternal()));
    }

    function _getIdInternal() internal view returns (uint32) {
        return _id;
    }

    function _setIdInternal(uint32 _newId) internal {
        uint32 previous = _id;
        _id = _newId;

        // Emit event about change
        emit IdChanged(
            _newId,
            previous
        );
    }

    function _getFactoryInternal() internal view returns (address) {
        return _factory;
    }

    function _setFactoryInternal(address _newFactory) internal {
        address previous = _factory;
        _factory = _newFactory;

        // Emit event about change
        emit FactoryChanged(
            _newFactory,
            previous
        );
    }
}
