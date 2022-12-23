pragma ever-solidity >= 0.61.2;

import "../../libraries/UtilityErrors.sol";
import "../../libraries/UtilityFlag.sol";

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

    function _getTargetBalanceInternal()
        internal
        virtual
        override
        view
        returns (uint128);

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
        virtual
        override
        reserveAndRefund(_getTargetBalanceInternal(), _remainingGasTo, msg.sender)
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
