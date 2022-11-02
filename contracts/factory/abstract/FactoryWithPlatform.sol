pragma ever-solidity >= 0.63.0;

import "../../libraries/UtilityErrors.sol";
import "../../libraries/UtilityFlag.sol";
import "../../libraries/UtilityGas.sol";

import "../interfaces/IFactoryWithPlatform.sol";

import "./Factory.sol";

/// @author Alexander Kunekov
/// @title Factory with Platform
/// @notice Implements base functions for factory with platform contract
abstract contract FactoryWithPlatform is
    IFactoryWithPlatform,
    Factory
{
    /// @dev Code for the new instance's root
    TvmCell private _platformCode;

    function getPlatformCode()
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
        } _platformCode;
    }

    function setPlatformCode(
        TvmCell _newPlatformCode,
        optional(address) _remainingGasTo
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        onlyOwner
        validTvmCell(_newPlatformCode, UtilityErrors.INVALID_CODE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        _setPlatformCodeInternal(_newPlatformCode);
    }

    /// @dev Internal call to set new platform code
    /// @dev Emits PlatformCodeSet event after update
    /// @param _newPlatformCode New root for instance
    function _setPlatformCodeInternal(TvmCell _newPlatformCode) internal {
        // Check that platform's code is not set yet
        require(
            _platformCode.toSlice().empty(),
            UtilityErrors.PLATFORM_CODE_ALREADY_SET
        );

        _platformCode = _newPlatformCode;

        // Emit event about change
        emit PlatformCodeSet();
    }

    /// @dev Use it inside onCodeUpgrade to set platform code without PlatformCodeSet event
    /// @param _newPlatformCode New root for instance
    function _setPlatformCodeSilent(TvmCell _newPlatformCode) internal {
        // Check that platform's code is not set yet
        require(
            _platformCode.toSlice().empty(),
            UtilityErrors.PLATFORM_CODE_ALREADY_SET
        );

        _platformCode = _newPlatformCode;
    }

    /// @dev Internal call to get current platform code
    /// @dev Use for contract upgrading, _getInstanceAddressInternal() and deploy()
    /// @return TvmCell Current platform code
    function _getPlatformCodeInternal() internal view returns (TvmCell) {
        return _platformCode;
    }
}
