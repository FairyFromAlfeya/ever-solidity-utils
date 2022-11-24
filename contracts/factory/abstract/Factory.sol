pragma ever-solidity >= 0.61.2;

import "../../access/abstract/Ownable.sol";

import "../../libraries/UtilityErrors.sol";
import "../../libraries/UtilityFlag.sol";
import "../../libraries/UtilityGas.sol";

import "../interfaces/IFactory.sol";

/// @author Alexander Kunekov
/// @title Factory
/// @notice Implements base functions for factory contract
abstract contract Factory is
    IFactory,
    Ownable
{
    /// @dev Code for the new instance
    TvmCell private _instanceCode;

    /// @dev Version of the _instanceCode
    uint32 private _instanceVersion;

    /// @dev Function can be called only by factory instance
    /// @param _deployParams Packed params which was used for deploy
    modifier onlyInstance(TvmCell _deployParams) {
        require(
            _getInstanceAddressInternal(_deployParams) == msg.sender,
            UtilityErrors.CALLER_IS_NOT_INSTANCE
        );
        _;
    }

    function getInstanceCode()
        external
        view
        override
        responsible
        returns (TvmCell)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } _instanceCode;
    }

    function getInstanceVersion()
        external
        view
        override
        responsible
        returns (uint32)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } _instanceVersion;
    }

    function getInstanceAddress(TvmCell _deployParams)
        external
        view
        override
        responsible
        returns (address)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } _getInstanceAddressInternal(_deployParams);
    }

    function setInstanceCode(
        TvmCell _newInstanceCode,
        optional(uint32) _newInstanceVersion,
        optional(address) _remainingGasTo
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        onlyOwner
        validTvmCell(_newInstanceCode, UtilityErrors.INVALID_CODE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        _setInstanceCodeInternal(
            _newInstanceCode,
            _newInstanceVersion
        );
    }

    /// @dev Internal call to set new instance code
    /// @dev Emits InstanceVersionChanged event after update
    /// @param _newInstanceCode New code for instance
    /// @param _newInstanceVersion New version for instance which must be set explicit
    function _setInstanceCodeInternal(
        TvmCell _newInstanceCode,
        optional(uint32) _newInstanceVersion
    ) internal {
        // Update code and version
        _instanceCode = _newInstanceCode;

        if (_newInstanceVersion.hasValue()) {
            _instanceVersion = _newInstanceVersion.get();
        } else {
            _instanceVersion += 1;
        }

        // Emit event about change
        emit InstanceVersionChanged(
            _instanceVersion,
            _instanceVersion - 1
        );
    }

    /// @dev Use it inside onCodeUpgrade to set instance code without InstanceVersionChanged event
    /// @param _newInstanceCode New code for instance
    function _setInstanceCodeSilent(TvmCell _newInstanceCode) internal {
        _instanceCode = _newInstanceCode;
    }

    /// @dev Use it inside onCodeUpgrade to set instance version without InstanceVersionChanged event
    /// @param _newInstanceVersion New version for instance
    function _setInstanceVersionSilent(uint32 _newInstanceVersion) internal {
        _instanceVersion = _newInstanceVersion;
    }

    /// @dev Internal call to get current instance code
    /// @dev Use for contract upgrading, _getInstanceAddressInternal() and deploy()
    /// @return TvmCell Current instance code
    function _getInstanceCodeInternal() internal view returns (TvmCell) {
        return _instanceCode;
    }

    /// @dev Internal call to get instance version
    /// @dev Use for contract upgrading and deploy()
    /// @return uint32 Current instance version
    function _getInstanceVersionInternal() internal view returns (uint32) {
        return _instanceVersion;
    }

    /// @dev Internal call to get instance address by specified deploy params
    /// @dev Should be implemented by developer
    /// @param _deployParams Packed params which was used for deploy
    /// @return address Expected instance's address
    function _getInstanceAddressInternal(TvmCell _deployParams)
        internal
        view
        virtual
        returns (address);
}
