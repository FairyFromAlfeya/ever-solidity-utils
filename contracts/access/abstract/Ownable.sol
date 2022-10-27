pragma ever-solidity >= 0.63.0;

import "../../libraries/UtilityErrors.sol";
import "../../libraries/UtilityFlag.sol";
import "../../libraries/UtilityGas.sol";

import "../../reservation/abstract/Reservable.sol";

import "../../validation/abstract/Validatable.sol";

import "../interfaces/IOwnable.sol";

/// @author Alexander Kunekov
/// @title Ownable
/// @notice Implements base functions for ownable contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Ownable is
    IOwnable,
    Reservable,
    Validatable
{
    /// @dev Current contract's owner
    address private _owner;

    /// @dev Only _owner can call function with this modifier
    modifier onlyOwner() {
        require(
            _owner.value != 0 &&
            msg.sender == _owner,
            UtilityErrors.CALLER_IS_NOT_OWNER
        );
        _;
    }

    function getOwner()
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
        } _owner;
    }

    function setOwner(
        address _newOwner,
        optional(address) _remainingGasTo
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        onlyOwner
        validAddress(_newOwner, UtilityErrors.INVALID_NEW_OWNER)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        _setOwnerInternal(_newOwner);
    }

    /// @dev Internal call to set new owner
    /// @dev Emits OwnerChanged event after update
    /// @param _newOwner New owner of the contract
    function _setOwnerInternal(address _newOwner) internal {
        address previous = _owner;
        _owner = _newOwner;

        // Emit event about change
        emit OwnerChanged(
            _newOwner,
            previous
        );
    }

    /// @dev Use it inside onCodeUpgrade to set owner without OwnerChanged event
    /// @param _newOwner New owner of the contract
    function _setOwnerSilent(address _newOwner) internal {
        _owner = _newOwner;
    }

    /// @dev Internal call to get current owner
    /// @dev Useful for contract upgrading to remember owner
    /// @return address Current owner of the contract
    function _getOwnerInternal() internal view returns (address) {
        return _owner;
    }
}
