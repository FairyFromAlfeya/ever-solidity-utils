pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";
import "../../../contracts/reservation/abstract/TargetBalance.sol";

contract FactoryInstance is Reservable, TargetBalance {
    uint32 internal static _id;
    address internal static _factory;

    function _getTargetBalanceInternal()
        internal
        view
        virtual
        override
        returns (uint128)
    {
        return UtilityGas.INITIAL_BALANCE;
    }

    constructor(address _remainingGasTo)
        public
        reserveAndRefund(_getTargetBalanceInternal(), _remainingGasTo, _remainingGasTo)
    {}

    function onCodeUpgrade(TvmCell _data) private {
        tvm.resetStorage();

        (
            uint32 id,
            address factory
        ) = abi.decode(_data, (
            uint32,
            address
        ));

        _id = id;
        _factory = factory;
    }

    function check(optional(address) _remainingGasTo)
        external
        view
        reserveAndRefund(_getTargetBalanceInternal(), _remainingGasTo, msg.sender)
    {
        console.log(format("Instance with ID: {}", _id));
    }
}
