pragma ton-solidity >= 0.57.1;

import "../../libraries/MsgFlag.sol";

import "../interfaces/IUpgradable.sol";

/// @title Upgradable
/// @notice Implements base functions for upgradable contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Upgradable is IUpgradable {
    /// @dev Current contract's version
    uint32 private _version;

    function getVersion()
        external
        override
        view
        responsible
        returns (uint32)
    {
        return {
            value: 0,
            flag: MsgFlag.REMAINING_GAS,
            bounce: false
        } _getVersionInternal();
    }

    /// @dev Internal call to update contract's version
    /// @param _newVersion New contract's version
    function _setVersionInternal(uint32 _newVersion) internal {
        uint32 previous = _version;
        _version = _newVersion;

        // Emit event about change
        emit VersionChanged(
            _newVersion,
            previous
        );
    }

    /// @dev Internal call to get contract's version
    /// @return uint32 Current contract's version
    function _getVersionInternal() internal view returns (uint32) {
        return _version;
    }
}
