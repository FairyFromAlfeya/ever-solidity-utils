pragma ton-solidity >= 0.57.1;

import "@broxus/contracts/contracts/libraries/MsgFlag.sol";

import "../../validation/abstract/Validatable.sol";

import "../interfaces/IOwnable.sol";

import "../libraries/AccessGas.sol";
import "../libraries/AccessErrors.sol";

abstract contract Ownable is IOwnable, Validatable {
    address private _owner;

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
        } _owner;
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
        tvm.rawReserve(AccessGas.INITIAL_BALANCE, 0);

        _setOwnerInternal(_newOwner);

        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    function _setOwnerInternal(address _newOwner) internal {
        address previous = _owner;
        _owner = _newOwner;

        emit OwnerChanged(_newOwner, previous);
    }
}
