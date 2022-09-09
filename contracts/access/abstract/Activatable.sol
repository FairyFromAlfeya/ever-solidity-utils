pragma ton-solidity >= 0.57.1;

import "../../libraries/MsgFlag.sol";
import "../../libraries/UtilityGas.sol";
import "../../libraries/UtilityErrors.sol";

import "../interfaces/IActivatable.sol";

import "./Ownable.sol";

/// @title Activatable
/// @notice Implements base functions for activatable contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Activatable is IActivatable, Ownable {
    /// @dev Whether or not contract is active
    bool private _isActive;

    /// @dev Function can be called only if the contract is active
    modifier onlyActive() {
        require(_isActive, UtilityErrors.CONTRACT_IS_NOT_ACTIVE);
        _;
    }

    function getActive()
        external
        override
        view
        responsible
        returns (bool)
    {
        return {
            value: 0,
            flag: MsgFlag.REMAINING_GAS,
            bounce: false
        } _getActiveInternal();
    }

    function setActive(
        bool _newActive,
        optional(address) _remainingGasTo
    )
        external
        override
        reserve(UtilityGas.INITIAL_BALANCE)
        onlyOwner
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Update
        _setActiveInternal(_newActive);

        // Gas recipient from params or msg.sender by default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        // Refund remaining gas to recipient
        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    /// @dev Internal call to set new active status
    /// @param _newActive New active status
    function _setActiveInternal(bool _newActive) internal {
        bool previous = _isActive;
        _isActive = _newActive;

        // Emit event about change
        emit ActiveChanged(
            _newActive,
            previous
        );
    }

    /// @dev Internal call to get active status
    /// @return bool Current active status
    function _getActiveInternal() internal view returns (bool) {
        return _isActive;
    }
}
