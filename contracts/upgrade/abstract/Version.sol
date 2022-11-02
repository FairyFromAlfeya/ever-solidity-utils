pragma ever-solidity >= 0.63.0;

import "../../libraries/UtilityFlag.sol";

import "../interfaces/IVersion.sol";

/// @author Alexander Kunekov
/// @title Version
/// @notice Implements base functions for versioned contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Version is IVersion {
    /// @dev Current contract's version
    uint32 private _currentVersion;

    /// @dev Previous contract's version
    uint32 private _previousVersion;

    function getVersion()
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
        } _currentVersion;
    }

    function getPreviousVersion()
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
        } _previousVersion;
    }

    /// @dev Internal call to update contract's version
    /// @param _newVersion New contract's version
    function _setVersionInternal(uint32 _newVersion) internal {
        uint32 previous = _previousVersion;
        _currentVersion = _newVersion;

        // Emit event about change
        emit VersionChanged(
            _newVersion,
            previous
        );
    }

    function _setPreviousVersionInternal(uint32 _newPreviousVersion) internal {
        _previousVersion = _newPreviousVersion;
    }

    /// @dev Internal call to get contract's current version
    /// @return uint32 Current contract's version
    function _getVersionInternal() internal view returns (uint32) {
        return _currentVersion;
    }

    /// @dev Internal call to get contract's previous version
    /// @return uint32 Previous contract's version
    function _getPreviousVersionInternal() internal view returns (uint32) {
        return _previousVersion;
    }
}
