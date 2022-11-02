pragma ever-solidity >= 0.63.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/upgrade/abstract/Upgrader.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../factory/FactoryExample.sol";

import "./UpgradableByRequestExample.sol";

contract UpgraderExample is FactoryExample, Upgrader {
    constructor(
        optional(address) _initialOwner,
        optional(address) _remainingGasTo
    )
        public
        FactoryExample(_initialOwner, _remainingGasTo)
    {}

    function _getInstanceAddressForUpgradeInternal(TvmCell _deployParams)
        internal
        view
        override
        returns (address)
    {
        return msg.sender;
    }

    function _getParamsForUpgradeInternal()
        internal
        view
        override
        returns (uint32, TvmCell)
    {
        return (
            _getInstanceVersionInternal(),
            _getInstanceCodeInternal()
        );
    }
}
