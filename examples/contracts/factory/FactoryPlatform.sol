pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";
import "../../../contracts/reservation/abstract/TargetBalance.sol";

contract FactoryPlatform is Reservable, TargetBalance {
    uint32 private static _id;
    address private static _factory;

    function _getTargetBalanceInternal()
        internal
        view
        override
        returns (uint128)
    {
        return UtilityGas.INITIAL_BALANCE;
    }

    constructor(
        TvmCell _code,
        address _remainingGasTo
    )
        public
        reserveAndRefund(_getTargetBalanceInternal(), _remainingGasTo, _remainingGasTo)
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
