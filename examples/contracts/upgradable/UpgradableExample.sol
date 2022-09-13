pragma ton-solidity >= 0.57.1;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/access/abstract/Ownable.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/upgrade/abstract/Upgradable.sol";

contract UpgradableExample is Upgradable, Ownable {
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
            flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    function upgrade(
        TvmCell _code,
        optional(address) _remainingGasTo
    )
        external
        override
        reserve(UtilityGas.INITIAL_BALANCE)
        validTvmCell(_code, UtilityErrors.INVALID_CODE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Gas recipient from params or default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        // Encode data from contract
        TvmCell data = abi.encode(
            _nonce,
            _getVersionInternal(),
            _getOwnerInternal(),
            remainingGasTo
        );

        // Update contract's code for current and next calls
        tvm.setcode(_code);
        tvm.setCurrentCode(_code);

        // Call onCodeUpgrade from new contract's code
        onCodeUpgrade(data);
    }

    function onCodeUpgrade(TvmCell _data) private {
        // Clear previous fields
        tvm.resetStorage();

        // Unpack data
        (
            uint32 nonce,
            uint32 version,
            address owner,
            address remainingGasTo
        ) = abi.decode(_data, (
            uint32,
            uint32,
            address,
            address
        ));

        // Set fields
        _nonce = nonce;
        _setOwnerInternal(owner);
        _setVersionInternal(++version);

        console.log(format("New version: {}", version));

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS,
            bounce: false
        });
    }
}
