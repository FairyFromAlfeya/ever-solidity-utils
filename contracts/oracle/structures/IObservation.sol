pragma ton-solidity >= 0.57.1;

/// @title Observation Interface
/// @notice Structure for packed point's info response
interface IObservation {
    /// @dev Point structure with UNIX timestamp in seconds
    struct Observation {
        /// @dev When the point was created
        uint32 timestamp;

        /// @dev FP128-cumulative for sums of token0 / token1 * timeElapsed
        uint price0To1Cumulative;

        /// @dev FP128-cumulative for sums of token1 / token0 * timeElapsed
        uint price1To0Cumulative;
    }
}
