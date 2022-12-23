pragma ever-solidity >= 0.61.2;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "../../../contracts/dex/libraries/DexPlatformTypes.sol";
import "../../../contracts/dex/DexPlatformMinimized.sol";

import "../../../contracts/libraries/UtilityFlag.sol";
import "../../../contracts/libraries/UtilityGas.sol";

import "../../../contracts/reservation/abstract/Reservable.sol";
import "../../../contracts/reservation/abstract/TargetBalance.sol";

import "../../../contracts/validation/abstract/Validatable.sol";

contract DexPlatformExample is
    Reservable,
    Validatable,
    TargetBalance
{
    uint32 private static _nonce;

    function _getTargetBalanceInternal()
        internal
        view
        override
        returns (uint128)
    {
        return UtilityGas.INITIAL_BALANCE;
    }

    constructor(optional(address) _remainingGasTo)
        public
        reserveAcceptAndRefund(_getTargetBalanceInternal(), _remainingGasTo, msg.sender)
    {}

    function getPairAddress(
        TvmCell _platformCode,
        address _root,
        address _left,
        address _right
    )
        external
        pure
        responsible
        returns (address)
    {
        TvmBuilder builder;

        builder.store(_left);
        builder.store(_right);

        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } address(
            tvm.hash(
                tvm.buildStateInit({
                    code: _platformCode,
                    contr: DexPlatformMinimized,
                    pubkey: 0,
                    varInit: {
                        root: _root,
                        type_id: DexPlatformTypes.POOL,
                        params: builder.toCell()
                    }
                })
            )
        );
    }
}
