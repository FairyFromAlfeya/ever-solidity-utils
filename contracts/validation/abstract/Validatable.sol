pragma ton-solidity >= 0.57.1;

import "../../libraries/UtilityFlag.sol";

import "../libraries/Validation.sol";

/// @title Validatable
/// @notice Modifiers for calls' validation
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Validatable {
    /// @dev Reserve contract's balance with flag 0 and accept to pay fees
    /// @param _reserve Balance to keep on the contract
    modifier reserveAndAccept(uint128 _reserve) {
        tvm.rawReserve(_reserve, 0);
        tvm.accept();
        _;
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

    /// @dev Reserve contract's balance with flag 0
    /// @param _reserve Balance to keep on the contract
    modifier reserve(uint128 _reserve) {
        tvm.rawReserve(_reserve, 0);
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

    /// @dev Check that address is not nil and doesn't equal contract's address
    /// @param _a Value to check
    /// @param _error Error code to throw if value is invalid
    modifier validAddress(
        address _a,
        uint16 _error
    ) {
        Validation.notEquals(
            _a,
            address(this),
            _error
        );
        _;
    }

    /// @dev Check that TvmCell is not empty
    /// @param _a Value to check
    /// @param _error Error code to throw if value is invalid
    modifier validTvmCell(
        TvmCell _a,
        uint16 _error
    ) {
        Validation.notEmpty(
            _a,
            _error
        );
        _;
    }

    /// @dev Check that address is valid if specified or null
    /// @param _a Value to check
    /// @param _error Error code to throw if value is invalid
    modifier validAddressOrNull(
        optional(address) _a,
        uint16 _error
    ) {
        if (_a.hasValue()) {
            Validation.notEquals(
                _a.get(),
                address(this),
                _error
            );
        }
        _;
    }
}
