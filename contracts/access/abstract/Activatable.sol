pragma ton-solidity >= 0.57.1;

import "@broxus/contracts/contracts/libraries/MsgFlag.sol";

import "../interfaces/IActivatable.sol";

import "../libraries/AccessGas.sol";
import "../libraries/AccessErrors.sol";

import "./Ownable.sol";

abstract contract Activatable is IActivatable, Ownable {
    bool private _isActive;

    modifier onlyActive() {
        require(_isActive, AccessErrors.CONTRACT_IS_NOT_ACTIVE);
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
        onlyOwner
        validAddressOrNull(_remainingGasTo, AccessErrors.INVALID_GAS_RECIPIENT)
    {
        tvm.rawReserve(AccessGas.INITIAL_BALANCE, 0);

        _setActiveInternal(_newActive);

        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    function _setActiveInternal(bool _newActive) internal {
        bool previous = _isActive;
        _isActive = _newActive;

        emit ActiveChanged(
            _newActive,
            previous
        );
    }

    function _getActiveInternal() internal view returns (bool) {
        return _isActive;
    }
}
