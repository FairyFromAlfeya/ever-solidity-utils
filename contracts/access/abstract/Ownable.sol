pragma ton-solidity >= 0.57.1;

import "@broxus/contracts/contracts/libraries/MsgFlag.sol";

import "../../validation/abstract/Validatable.sol";

import "../interfaces/IOwnable.sol";

import "../libraries/AccessGas.sol";
import "../libraries/AccessErrors.sol";

/// @title Ownable
/// @notice Implements base functions for ownable contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Ownable is IOwnable, Validatable {
    /// @dev Current contract's owner
    address private _owner;

    /// @dev Only owner can call function with this modifier
    modifier onlyOwner() {
        require(
            _owner.value != 0 &&
            msg.sender == _owner,
            AccessErrors.CALLER_IS_NOT_OWNER
        );
        _;
    }

    function getOwner()
        external
        override
        view
        responsible
        returns (address)
    {
        return {
            value: 0,
            flag: MsgFlag.REMAINING_GAS,
            bounce: false
        } _getOwnerInternal();
    }

    function setOwner(
        address _newOwner,
        optional(address) _remainingGasTo
    )
        external
        override
        onlyOwner
        validAddress(_newOwner, AccessErrors.INVALID_NEW_OWNER)
        validAddressOrNull(_remainingGasTo, AccessErrors.INVALID_GAS_RECIPIENT)
    {
        // Reserve contract's balance
        tvm.rawReserve(AccessGas.INITIAL_BALANCE, 0);

        // Update
        _setOwnerInternal(_newOwner);

        // Gas recipient from params or msg.sender by default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        // Refund remaining gas to recipient
        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    /// @dev Internal call to set new owner
    /// @param _newOwner New contract's owner
    function _setOwnerInternal(address _newOwner) internal {
        address previous = _owner;
        _owner = _newOwner;

        // Emits event about change
        emit OwnerChanged(
            _newOwner,
            previous
        );
    }

    /// @dev Internal call to get current owner
    /// @return address Current contract's owner
    function _getOwnerInternal() internal view returns (address) {
        return _owner;
    }
}
