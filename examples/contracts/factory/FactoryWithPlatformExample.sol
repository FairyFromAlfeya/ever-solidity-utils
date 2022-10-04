pragma ton-solidity >= 0.57.1;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/factory/abstract/FactoryWithPlatform.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "./FactoryPlatform.sol";

contract FactoryWithPlatformExample is FactoryWithPlatform {
    // Random number for contract redeploy with another address
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
        // Owner from params or default
        address initialOwner = _initialOwner.hasValue() ? _initialOwner.get() : msg.sender;

        // Initialize owner
        _setOwnerInternal(initialOwner);
    }

    // Encode child contract's initial params
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

    function getInstanceAddress(TvmCell _params)
        external
        view
        override
        responsible
        returns (address)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } address(
            tvm.hash(
                tvm.buildStateInit({
                    code: _getPlatformCodeInternal(),
                    contr: FactoryPlatform,
                    pubkey: 0,
                    varInit: {
                        _id: abi.decode(_params, uint32),
                        _factory: address(this)
                    }
                })
            )
        );
    }

    function deploy(
        TvmCell _params,
        optional(address) _remainingGasTo
    )
        external
        override
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        validTvmCell(_params, UtilityErrors.INVALID_CODE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Build state init for deploy
        TvmCell data = tvm.buildStateInit({
            code: _getPlatformCodeInternal(),
            contr: FactoryPlatform,
            pubkey: 0,
            varInit: {
                _id: abi.decode(_params, uint32),
                _factory: address(this)
            }
        });

        // Deploy new instance
        address instance = new FactoryPlatform{
            stateInit: data,
            value: 2 ever,
            flag: UtilityFlag.SENDER_PAYS_FEES,
            bounce: false
        }(
            _getInstanceCodeInternal(),
            _remainingGasTo
        );

        emit InstanceDeployed(
            instance,
            _getInstanceVersionInternal(),
            msg.sender
        );
    }
}
