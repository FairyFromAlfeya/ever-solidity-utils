pragma ton-solidity >= 0.57.1;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/factory/abstract/Factory.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "./FactoryInstance.sol";

contract FactoryExample is Factory {
    // Random number for contract redeploy with another address
    uint32 private static _nonce;

    constructor(
        optional(address) _initialOwner,
        optional(address) _remainingGasTo
    )
        public
        reserveAndAccept(UtilityGas.INITIAL_BALANCE)
        validAddressOrNull(_initialOwner, UtilityErrors.INVALID_NEW_OWNER)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Owner from params or default
        address initialOwner = _initialOwner.hasValue() ? _initialOwner.get() : msg.sender;

        // Initialize owner
        _setOwnerInternal(initialOwner);

        // Gas recipient from params or default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
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
            flag: MsgFlag.REMAINING_GAS,
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
            flag: MsgFlag.REMAINING_GAS,
            bounce: false
        } address(
            tvm.hash(
                tvm.buildStateInit({
                    code: _getInstanceCodeInternal(),
                    contr: FactoryInstance,
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
        reserve(UtilityGas.INITIAL_BALANCE)
        validTvmCell(_params, UtilityErrors.INVALID_CODE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Build state init for deploy
        TvmCell data = tvm.buildStateInit({
            code: _getInstanceCodeInternal(),
            contr: FactoryInstance,
            pubkey: 0,
            varInit: {
                _id: abi.decode(_params, uint32),
                _factory: address(this)
            }
        });

        // Deploy new instance
        address instance = new FactoryInstance{
            stateInit: data,
            value: 2 ever,
            flag: MsgFlag.SENDER_PAYS_FEES,
            bounce: false
        }(_remainingGasTo);

        emit InstanceDeployed(
            instance,
            _getInstanceVersionInternal(),
            msg.sender
        );

        // Gas recipient from params or default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: MsgFlag.ALL_NOT_RESERVED + MsgFlag.IGNORE_ERRORS,
            bounce: false
        });
    }
}
