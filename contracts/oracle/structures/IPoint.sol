pragma ton-solidity >= 0.57.1;

/// @title Point Interface
/// @notice Root structure for the point
interface IPoint {
    /// @dev Root structure for each oracle's write
    struct Point {
        /// @dev FP128-cumulative for sums of token0 / token1 * timeElapsed
        uint price0To1Cumulative;

        /// @dev FP128-cumulative for sums of token1 / token0 * timeElapsed
        uint price1To0Cumulative;
    }
}
