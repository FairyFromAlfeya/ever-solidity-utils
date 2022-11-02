pragma ever-solidity >= 0.63.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";

contract FactoryPlatform is Reservable {
    uint32 private static _id;
    address private static _factory;

    constructor(
        TvmCell _code,
        address _remainingGasTo
    )
        public
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, _remainingGasTo)
    {
        _upgrade(_code);
    }

    function _upgrade(TvmCell _code) private {
        TvmCell data = abi.encode(_id, _factory);

        tvm.setcode(_code);
        tvm.setCurrentCode(_code);

        onCodeUpgrade(data);
    }

    function onCodeUpgrade(TvmCell _data) private {}
}
