pragma ever-solidity >= 0.63.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "locklift/src/console.sol";

import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";

contract FactoryInstance is Reservable {
    uint32 internal static _id;
    address internal static _factory;

    constructor(address _remainingGasTo)
        public
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, _remainingGasTo)
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
        reserveAndRefund(UtilityGas.INITIAL_BALANCE, _remainingGasTo, msg.sender)
    {
        console.log(format("Instance with ID: {}", _id));
    }
}
