pragma ever-solidity >= 0.61.2;

import "../../libraries/UtilityFlag.sol";

/// @author Alexander Kunekov
/// @title Reservable
/// @notice Modifiers for contract's balance reservation
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Reservable {
    /// @dev Reserve contract's balance with flag 0
    /// @param _reserve Balance to keep on the contract
    modifier reserve(uint128 _reserve) {
        tvm.rawReserve(_reserve, 0);
        _;
    }

    /// @dev Reserve contract's balance with flag 0 and accept to pay fees
    /// @param _reserve Balance to keep on the contract
    modifier reserveAndAccept(uint128 _reserve) {
        tvm.rawReserve(_reserve, 0);
        tvm.accept();
        _;
    }

    /// @dev Reserve contract's balance with flag 0 and refund remaining gas
    /// @param _reserve Balance to keep on the contract
    /// @param _remainingGasTo Gas recipient
    /// @param _fallback Extra gas recipient if _remainingGasTo is invalid
    modifier reserveAndRefund(
        uint128 _reserve,
        optional(address) _remainingGasTo,
        address _fallback
    ) {
        tvm.rawReserve(_reserve, 0);

        // Gas recipient from params or nil address
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : address(0);

        // Use fallback address if recipient is nil or this
        if (remainingGasTo.value == 0 || remainingGasTo == address(this)) {
            remainingGasTo = _fallback;
        }

        _;

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS,
            bounce: false
        });
    }

    /// @dev Reserve contract's balance with flag 0, accept to pay fees and refund remaining gas
    /// @param _reserve Balance to keep on the contract
    /// @param _remainingGasTo Gas recipient
    /// @param _fallback Extra gas recipient if _remainingGasTo is invalid
    modifier reserveAcceptAndRefund(
        uint128 _reserve,
        optional(address) _remainingGasTo,
        address _fallback
    ) {
        tvm.rawReserve(_reserve, 0);
        tvm.accept();

        // Gas recipient from params or nil address
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : address(0);

        // Use fallback address if recipient is nil or this
        if (remainingGasTo.value == 0 || remainingGasTo == address(this)) {
            remainingGasTo = _fallback;
        }

        _;

        // Refund remaining gas
        remainingGasTo.transfer({
            value: 0,
            flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS,
            bounce: false
        });
    }
}
