pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/upgrade/abstract/UpgradableByRequest.sol";

import "../factory/FactoryInstance.sol";

contract UpgradableByRequestExample is FactoryInstance, UpgradableByRequest {
    constructor(address _remainingGasTo)
        public
        FactoryInstance(_remainingGasTo)
    {
        _setUpgraderInternal(_factory);
        _setCurrentVersionInternal(1, 0);
    }

    function upgrade(
        uint32 _version,
        TvmCell _code,
        address _remainingGasTo
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        onlyUpgrader
        validTvmCell(_code, UtilityErrors.INVALID_CODE)
    {
        TvmCell data = abi.encode(
            _id,
            _version,
            _getCurrentVersionInternal(),
            _factory,
            _getUpgraderInternal()
        );

        tvm.setcode(_code);
        tvm.setCurrentCode(_code);

        _onUpgrade(data);
    }

    function _onUpgrade(TvmCell _data) private {
        tvm.resetStorage();

        (
            uint32 id,
            uint32 currentVersion,
            uint32 previousVersion,
            address factory,
            address upgrader
        ) = abi.decode(_data, (
            uint32,
            uint32,
            uint32,
            address,
            address
        ));

        _id = id;
        _factory = factory;

        _setCurrentVersionInternal(currentVersion, previousVersion);
        _setUpgraderSilent(upgrader);

        console.log(format("New version: {}", _getCurrentVersionInternal()));
    }

    function _getDeployParamsInternal()
        internal
        view
        override
        returns (TvmCell)
    {
        return abi.encode(_id);
    }
}
