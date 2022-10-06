pragma ton-solidity >= 0.57.1;

/// @title Rate Interface
/// @notice Structure for packed rate info response
interface IRate {
    /// @dev Packed rate info that needs to be returned
    struct Rate {
        /// @dev FP128-price calculated from points' price0To1Cumulative
        uint price0To1;

        /// @dev FP128-price calculated from point's price1To0Cumulative
        uint price1To0;

        /// @dev From-point's timestamp in UNIX seconds
        uint32 fromTimestamp;

        /// @dev To-point's timestamp in UNIX seconds
        uint32 toTimestamp;
    }
}
