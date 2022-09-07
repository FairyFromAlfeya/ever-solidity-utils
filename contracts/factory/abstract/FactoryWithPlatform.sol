pragma ton-solidity >= 0.57.1;

import "@broxus/contracts/contracts/libraries/MsgFlag.sol";

import "../../libraries/UtilityGas.sol";
import "../../libraries/UtilityErrors.sol";

import "../interfaces/IFactoryWithPlatform.sol";

import "./Factory.sol";

/// @title Factory with Platform
/// @notice Implements base functions for factory with platform contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract FactoryWithPlatform is IFactoryWithPlatform, Factory {
    /// @dev Code for the new instance's root
    TvmCell private _platformCode;

    function getPlatformCode()
        external
        override
        view
        responsible
        returns (TvmCell)
    {
        return {
            value: 0,
            flag: MsgFlag.REMAINING_GAS,
            bounce: false
        } _getPlatformCodeInternal();
    }

    function setPlatformCode(
        TvmCell _newCode,
        optional(address) _remainingGasTo
    )
        external
        override
        reserve(UtilityGas.INITIAL_BALANCE)
        onlyOwner
        validTvmCell(_newCode, UtilityErrors.INVALID_CODE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Check that platform's code is not set yet
        require(
            _getPlatformCodeInternal().toSlice().empty(),
            UtilityErrors.PLATFORM_CODE_ALREADY_SET
        );

        // Update
        _setPlatformCodeInternal(_newCode);

        // Gas recipient from params or msg.sender by default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        // Refund remaining gas to recipient
        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    /// @dev Internal call to set new platform code
    /// @param _newCode New platform code
    function _setPlatformCodeInternal(TvmCell _newCode) internal {
        // Update code
        _platformCode = _newCode;

        // Emit event about change
        emit PlatformCodeSet();
    }

    /// @dev Internal call to get platform code
    /// @return TvmCell Current platform code
    function _getPlatformCodeInternal() internal view returns (TvmCell) {
        return _platformCode;
    }
}
