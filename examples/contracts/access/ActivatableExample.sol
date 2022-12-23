pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/access/abstract/Activatable.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

contract ActivatableExample is Activatable {
    uint32 private static _nonce;

    function _getTargetBalanceInternal()
        internal
        view
        override
        returns (uint128)
    {
        return UtilityGas.INITIAL_BALANCE;
    }

    constructor(
        optional(address) _initialOwner,
        optional(address) _remainingGasTo
    )
        public
        reserveAcceptAndRefund(_getTargetBalanceInternal(), _remainingGasTo, msg.sender)
        validAddressOrNull(_initialOwner, UtilityErrors.INVALID_NEW_OWNER)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        address initialOwner = _initialOwner.hasValue() ? _initialOwner.get() : msg.sender;

        _setOwnerInternal(initialOwner);
    }

    function check(optional(address) _remainingGasTo)
        external
        view
        reserveAndRefund(_getTargetBalanceInternal(), _remainingGasTo, msg.sender)
        onlyActive
    {
        console.log(format("Contract is active: {}", _nonce));
    }
}
