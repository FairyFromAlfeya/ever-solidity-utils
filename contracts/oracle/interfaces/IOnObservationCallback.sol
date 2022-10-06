pragma ton-solidity >= 0.57.1;

import "../structures/IObservation.sol";

/// @title OnObservation-callback Interface
/// @notice Interface for onObservation-callback implementation
interface IOnObservationCallback is IObservation {
    /// @notice Handle callback of observation call
    /// @param _observation Observation by timestamp or null if the point with this timestamp doesn't exist
    /// @param _payload Any extra data from the previous call
    function onObservationCallback(
        optional(Observation) _observation,
        TvmCell _payload
    ) external;
}
