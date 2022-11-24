pragma ever-solidity >= 0.61.2;

import "../libraries/Validation.sol";

/// @author Alexander Kunekov
/// @title Validatable
/// @notice Modifiers for calls' validation
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Validatable {
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
