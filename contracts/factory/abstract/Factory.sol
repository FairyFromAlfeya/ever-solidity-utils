pragma ton-solidity >= 0.57.1;

import "../../access/abstract/Ownable.sol";

import "../../libraries/UtilityFlag.sol";
import "../../libraries/UtilityGas.sol";
import "../../libraries/UtilityErrors.sol";

import "../interfaces/IFactory.sol";

/// @title Factory
/// @notice Implements base functions for factory contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Factory is IFactory, Ownable {
    /// @dev Code for the new instance
    TvmCell private _instanceCode;

    /// @dev Version of the instance's code
    uint32 private _instanceVersion;

    function getInstanceCode()
        external
        override
        view
        responsible
        returns (TvmCell)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } _getInstanceCodeInternal();
    }

    function getInstanceVersion()
        external
        override
        view
        responsible
        returns (uint32)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } _getInstanceVersionInternal();
    }

    function setInstanceCode(
        TvmCell _newCode,
        optional(address) _remainingGasTo
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        onlyOwner
        validTvmCell(_newCode, UtilityErrors.INVALID_CODE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Update
        _setInstanceCodeInternal(_newCode);
    }

    /// @dev Internal call to set new instance code
    /// @param _newCode New instance code
    function _setInstanceCodeInternal(TvmCell _newCode) internal {
        // Update code and version
        _instanceCode = _newCode;
        _instanceVersion += 1;

        // Emit event about change
        emit InstanceVersionChanged(
            _instanceVersion,
            _instanceVersion - 1
        );
    }

    function _setInstanceCodeSilent(TvmCell _newCode) internal {
        _instanceCode = _newCode;
    }

    function _setInstanceVersionSilent(uint32 _version) internal {
        _instanceVersion = _version;
    }

    /// @dev Internal call to get instance code
    /// @return TvmCell Current instance code
    function _getInstanceCodeInternal() internal view returns (TvmCell) {
        return _instanceCode;
    }

    /// @dev Internal call to get instance code version
    /// @return uint32 Current instance code version
    function _getInstanceVersionInternal() internal view returns (uint32) {
        return _instanceVersion;
    }
}
