pragma ever-solidity >= 0.63.0;

import "../structures/IRate.sol";

import "./IOracle.sol";

/// @author Alexander Kunekov
/// @title TWAP-Oracle Interface
/// @notice Interface for interaction with pair's TWAP-Oracle
interface ITWAPOracle is IRate, IOracle {
    /// @notice Get observation by timestamp
    /// @param _timestamp UNIX timestamp in seconds of the observation
    /// @return optional(Observation) Observation by timestamp or null if it doesn't exist
    function getObservation(uint32 _timestamp)
        external
        view
        responsible
        returns (optional(Observation));

    /// @notice Get a callback with an observation by timestamp
    /// @param _timestamp UNIX timestamp in seconds of the observation
    /// @param _payload Any extra data to return in callback
    function observation(
        uint32 _timestamp,
        TvmCell _payload
    ) external view;

    /// @notice Calculates TWAP for the given interval
    /// @dev If there is no point with a timestamp equal to _fromTimestamp or _toTimestamp
    ///      will take the point with the nearest timestamp
    /// @param _fromTimestamp Start of interval for TWAP
    /// @param _toTimestamp End of interval for TWAP
    /// @return (optional(Rate), uint128[]) Packed rate info in the time range between _fromTimestamp and _toTimestamp
    ///         or null if impossible to calculate + current pair's reserves
    function getRate(
        uint32 _fromTimestamp,
        uint32 _toTimestamp
    )
        external
        view
        responsible
        returns (optional(Rate), uint128[]);

    /// @notice Get a callback with calculated TWAP for the given interval
    /// @dev If there is no point with a timestamp equal to _fromTimestamp or _toTimestamp
    ///      will take the point with the nearest timestamp
    /// @param _fromTimestamp Start of interval for TWAP
    /// @param _toTimestamp End of interval for TWAP
    /// @param _callbackTo Recipient of the callback
    /// @param _payload Any extra data to return in callback
    function rate(
        uint32 _fromTimestamp,
        uint32 _toTimestamp,
        address _callbackTo,
        TvmCell _payload
    ) external view;

    /// @notice Calculates expected amount using given params and TWAP
    /// @dev Can be reverted if impossible to calculate TWAP
    /// @param _amount First token amount
    /// @param _tokenRoot Address of the first token root
    /// @param _fromTimestamp Start of interval for TWAP
    /// @param _toTimestamp End of interval for TWAP
    /// @return uint128 Expected amount of the second token
    function getExpectedAmountByTWAP(
        uint128 _amount,
        address _tokenRoot,
        uint32 _fromTimestamp,
        uint32 _toTimestamp
    )
        external
        view
        responsible
        returns (uint128);
}
