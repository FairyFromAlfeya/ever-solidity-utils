pragma ton-solidity >= 0.57.1;

/// @title Oracle Options Interface
/// @notice Structure for packed oracle's options
interface IOracleOptions {
    /// @dev Options structure
    struct OracleOptions {
        /// @dev Minimum interval in seconds between points up to 255 seconds(4.25 minutes)
        uint8 minInterval;

        /// @dev Minimum rate percent delta numerator to write the next point
        uint128 minRateDeltaNumerator;

        /// @dev Minimum rate percent delta denominator to write the next point
        uint128 minRateDeltaDenominator;

        /// @dev Maximum count of points up to 65535
        uint16 cardinality;
    }
}
