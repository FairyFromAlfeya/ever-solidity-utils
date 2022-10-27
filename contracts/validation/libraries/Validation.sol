pragma ever-solidity >= 0.63.0;

/// @author Alexander Kunekov
/// @title Validation Utility
library Validation {
    /// @notice Check that addresses are different and not nil
    /// @param _a First address
    /// @param _b Second address
    /// @param _error Error code if validation was failed
    function notEquals(
        address _a,
        address _b,
        uint16 _error
    ) public {
        require(
            _a.value != 0 &&
            _b.value != 0 &&
            _a != _b,
            _error
        );
    }

    /// @notice Check that TvmCell is not empty
    /// @param _a TvmCell for check
    /// @param _error Error code if validation was failed
    function notEmpty(
        TvmCell _a,
        uint16 _error
    ) public {
        require(!_a.toSlice().empty(), _error);
    }
}
