pragma ton-solidity >= 0.57.1;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/upgrade/abstract/Upgrader.sol";

import "../factory/FactoryExample.sol";

contract UpgraderExample is FactoryExample, Upgrader {
    constructor(
        optional(address) _initialOwner,
        optional(address) _remainingGasTo
    ) public FactoryExample(_initialOwner, _remainingGasTo) {}

    function _getInstanceVersionForUpgradeInternal()
        internal
        view
        override
        returns (uint32)
    {
        return _getInstanceVersionInternal();
    }

    function _getInstanceCodeForUpgradeInternal()
        internal
        view
        override
        returns (TvmCell)
    {
        return _getInstanceCodeInternal();
    }

    function _getInstanceAddressForUpgradeInternal(TvmCell _params)
        internal
        view
        override
        returns (address)
    {
        return _getInstanceAddressInternal(_params);
    }
}
