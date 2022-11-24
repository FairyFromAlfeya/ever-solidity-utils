pragma ever-solidity >= 0.61.2;

import "../../libraries/UtilityErrors.sol";
import "../../libraries/UtilityFlag.sol";
import "../../libraries/UtilityGas.sol";

import "../interfaces/IActivatable.sol";

import "./Ownable.sol";

/// @author Alexander Kunekov
/// @title Activatable
/// @notice Implements base functions for activatable contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Activatable is
    IActivatable,
    Ownable
{
    /// @dev Whether or not a contract is active
    bool private _isActive;

    /// @dev Function can be called only if the contract is active
    modifier onlyActive() {
        require(_isActive, UtilityErrors.CONTRACT_IS_NOT_ACTIVE);
        _;
    }

    function getActiveStatus()
        external
        view
        override
        responsible
        returns (bool)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } _isActive;
    }

    function setActiveStatus(
        bool _newActiveStatus,
        optional(address) _remainingGasTo
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        onlyOwner
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        _setActiveStatusInternal(_newActiveStatus);
    }

    /// @dev Internal call to set new active status
    /// @dev Emits ActiveStatusChanged event after update
    /// @param _newActiveStatus New active status of the contract
    function _setActiveStatusInternal(bool _newActiveStatus) internal {
        bool previous = _isActive;
        _isActive = _newActiveStatus;

        // Emit event about change
        emit ActiveStatusChanged(
            _newActiveStatus,
            previous
        );
    }

    /// @dev Use it inside onCodeUpgrade to set active status without ActiveStatusChanged event
    /// @param _newActiveStatus New active status of the contract
    function _setActiveStatusSilent(bool _newActiveStatus) internal {
        _isActive = _newActiveStatus;
    }

    /// @dev Internal call to get current active status
    /// @dev Useful for contract upgrading to remember active status
    /// @return bool Current active status of the contract
    function _getActiveStatusInternal() internal view returns (bool) {
        return _isActive;
    }
}
