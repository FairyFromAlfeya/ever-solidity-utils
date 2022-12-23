pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/upgrade/abstract/Version.sol";

import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";
import "../../../contracts/reservation/abstract/TargetBalance.sol";

contract VersionExample is
    Version,
    Reservable,
    TargetBalance
{
    uint32 private static _nonce;

    function _getTargetBalanceInternal()
        internal
        view
        override
        returns (uint128)
    {
        return UtilityGas.INITIAL_BALANCE;
    }

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(_getTargetBalanceInternal(), _remainingGasTo, msg.sender)
    {
        _setCurrentVersionInternal(1, 0);
    }
}
