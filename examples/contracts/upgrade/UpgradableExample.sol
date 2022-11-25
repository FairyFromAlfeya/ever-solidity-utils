pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/access/abstract/Ownable.sol";

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityFlag.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/upgrade/abstract/Upgradable.sol";

contract UpgradableExample is Upgradable, Ownable {
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
        _setCurrentVersionInternal(1, 0);
    }

    function upgrade(
        TvmCell _code,
        optional(address) _remainingGasTo
    )
        external
        override
        reserve(UtilityGas.INITIAL_BALANCE)
        onlyOwner
        validTvmCell(_code, UtilityErrors.INVALID_CODE)
    {
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        TvmCell data = abi.encode(
            _nonce,
            _getCurrentVersionInternal(),
            _getOwnerInternal(),
            remainingGasTo
        );

        tvm.setcode(_code);
        tvm.setCurrentCode(_code);

        onCodeUpgrade(data);
    }

    function onCodeUpgrade(TvmCell _data) private {
        tvm.resetStorage();

        (
            uint32 nonce,
            uint32 previousVersion,
            address owner,
            address remainingGasTo
        ) = abi.decode(_data, (
            uint32,
            uint32,
            address,
            address
        ));

        _nonce = nonce;
        _setOwnerSilent(owner);
        _setCurrentVersionInternal(previousVersion + 1, previousVersion);

        console.log(format("New version: {}", _getCurrentVersionInternal()));

        remainingGasTo.transfer({
            value: 0,
            flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS,
            bounce: false
        });
    }
}
