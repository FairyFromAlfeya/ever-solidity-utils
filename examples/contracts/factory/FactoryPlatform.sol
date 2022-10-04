pragma ton-solidity >= 0.57.1;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/libraries/UtilityErrors.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/validation/abstract/Validatable.sol";

contract FactoryPlatform is Validatable {
    // ID for contract redeploy with another address
    uint32 private static _id;

    // Address of the factory
    address private static _factory;

    constructor(
        TvmCell _code,
        optional(address) _remainingGasTo
    )
        public
        reserveAcceptAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
        validTvmCell(_code, UtilityErrors.INVALID_CODE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        _upgrade(_code);
    }

    function _upgrade(TvmCell _code) private {
        // Encode data from contract
        TvmCell data = abi.encode(_id, _factory);

        // Update contract's code for current and next calls
        tvm.setcode(_code);
        tvm.setCurrentCode(_code);

        // Call onCodeUpgrade from instance's code
        onCodeUpgrade(data);
    }

    function onCodeUpgrade(TvmCell _data) private {}
}
