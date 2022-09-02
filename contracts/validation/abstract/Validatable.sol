pragma ton-solidity >= 0.57.1;

import "../libraries/Validation.sol";

/// @title Validatable
/// @notice Modifiers for calls' validation
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Validatable {
    /// @dev Reserve contract's balance with flag 0 and accept to pay fees
    modifier reserveAndAccept(uint128 _reserve) {
        tvm.rawReserve(_reserve, 0);
        tvm.accept();
        _;
    }

    /// @dev Reserve contract's balance with flag 0
    modifier reserve(uint128 _reserve) {
        tvm.rawReserve(_reserve, 0);
        _;
    }

    /// @dev Check that address is not nil and doesn't equal contract's address
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
