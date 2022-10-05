pragma ton-solidity >= 0.57.1;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/upgrade/abstract/UpgradableByRequest.sol";

import "../factory/FactoryInstance.sol";

contract UpgradableByRequestExample is FactoryInstance, UpgradableByRequest {
    constructor(optional(address) _remainingGasTo)
        public
        FactoryInstance(_remainingGasTo)
    {
        _setUpgraderInternal(_getFactoryInternal());
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
        validAddress(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Encode data from contract
        TvmCell data = abi.encode(
            _getIdInternal(),
            _version,
            _getFactoryInternal(),
            _getUpgraderInternal()
        );

        tvm.setcode(_code);
        tvm.setCurrentCode(_code);

        _onUpgrade(data);
    }

    function _onUpgrade(TvmCell _data) private {
        // Clear previous fields
        tvm.resetStorage();

        // Unpack data
        (
            uint32 id,
            uint32 version,
            address factory,
            address upgrader
        ) = abi.decode(_data, (
            uint32,
            uint32,
            address,
            address
        ));

        // Set fields
        _setIdInternal(id);
        _setVersionInternal(version);
        _setFactoryInternal(factory);
        _setUpgraderInternal(upgrader);

        console.log(format("New version: {}", _getVersionInternal()));
    }

    function _getDeployParamsInternal()
        internal
        view
        override
        returns (TvmCell)
    {
        return abi.encode(_getIdInternal());
    }
}
