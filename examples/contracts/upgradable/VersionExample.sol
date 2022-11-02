pragma ever-solidity >= 0.63.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/upgrade/abstract/Upgrader.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../factory/FactoryExample.sol";

import "./UpgradableByRequestExample.sol";

contract VersionExample is Version, Reservable {
    // Random number for contract redeploy with another address
    uint32 private static _nonce;

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
    {
        _setVersionInternal(1);
    }
}
