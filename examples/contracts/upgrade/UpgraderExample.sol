pragma ever-solidity >= 0.63.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/factory/abstract/Factory.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/upgrade/abstract/Upgrader.sol";

import "../factory/FactoryInstance.sol";

contract UpgraderExample is Factory, Upgrader {
    uint32 private static _nonce;

    constructor(
        optional(address) _initialOwner,
        optional(address) _remainingGasTo
    )
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        validAddressOrNull(_initialOwner, UtilityErrors.INVALID_NEW_OWNER)
    {
        address initialOwner = _initialOwner.hasValue() ? _initialOwner.get() : msg.sender;

        _setOwnerInternal(initialOwner);
    }

    function getDeployParams(uint32 _id)
        external
        pure
        responsible
        returns (TvmCell)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } abi.encode(_id);
    }

    function deploy(
        TvmCell _deployParams,
        optional(address) _remainingGasTo
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        validTvmCell(_deployParams, UtilityErrors.INVALID_DEPLOY_PARAMS)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        TvmCell data = tvm.buildStateInit({
            code: _getInstanceCodeInternal(),
            contr: FactoryInstance,
            pubkey: 0,
            varInit: {
                _id: abi.decode(_deployParams, uint32),
                _factory: address(this)
            }
        });

        address instance = new FactoryInstance{
            stateInit: data,
            value: 2 ever,
            flag: UtilityFlag.SENDER_PAYS_FEES,
            bounce: false
        }(_remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender);

        emit InstanceDeployed(
            instance,
            _deployParams,
            _getInstanceVersionInternal(),
            msg.sender
        );
    }

    function _getInstanceAddressInternal(TvmCell _deployParams)
        internal
        view
        override (Factory, Upgrader)
        returns (address)
    {
        return address(
            tvm.hash(
                tvm.buildStateInit({
                    code: _getInstanceCodeInternal(),
                    contr: FactoryInstance,
                    pubkey: 0,
                    varInit: {
                        _id: abi.decode(_deployParams, uint32),
                        _factory: address(this)
                    }
                })
            )
        );
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