pragma ever-solidity >= 0.63.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/access/abstract/Activatable.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

contract ActivatableExample is Activatable {
    uint32 private static _nonce;

    constructor(
        optional(address) _initialOwner,
        optional(address) _remainingGasTo
    )
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        validAddressOrNull(_initialOwner, UtilityErrors.INVALID_NEW_OWNER)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        address initialOwner = _initialOwner.hasValue() ? _initialOwner.get() : msg.sender;

        _setOwnerInternal(initialOwner);
    }

    function check(optional(address) _remainingGasTo)
        external
        view
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        onlyActive
    {
        console.log(format("Contract is active: {}", _nonce));
    }
}
