pragma ton-solidity >= 0.57.0;

/// @title Oracle Errors
/// @notice Possible errors when interacting with oracle contracts
library OracleErrors {
    /// @dev Invalid amount
    uint16 constant WRONG_AMOUNT = 134;

    /// @dev Invalid TokenRoot address for pair
    uint16 constant WRONG_TOKEN_ROOT = 135;

    /// @dev The timestamp must be positive
    uint16 constant NON_POSITIVE_TIMESTAMP = 136;

    /// @dev fromTimestamp must be lower or equal to the toTimestamp
    uint16 constant FROM_IS_BIGGER_THAN_TO = 137;

    /// @dev Oracle was already initialized
    uint16 constant ALREADY_INITIALIZED = 138;

    /// @dev Oracle is not initialized
    uint16 constant NOT_INITIALIZED = 139;

    /// @dev A new cardinality must be bigger or equal to the previous
    uint16 constant LOWER_CARDINALITY = 140;

    /// @dev Count can not be zero
    uint16 constant NON_POSITIVE_COUNT = 141;

    /// @dev Count is bigger than current array's length
    uint16 constant BIGGER_THAN_LENGTH = 142;

    /// @dev Denominator can not be zero
    uint16 constant NON_POSITIVE_DENOMINATOR = 143;

    /// @dev Impossible to calculate TWAP for given timestamps
    uint16 constant CAN_NOT_CALCULATE_TWAP = 144;
}
