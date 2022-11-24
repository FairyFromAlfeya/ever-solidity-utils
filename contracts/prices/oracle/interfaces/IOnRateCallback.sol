pragma ever-solidity >= 0.61.2;

import "../structures/IRate.sol";

/// @author Alexander Kunekov
/// @title OnRate-callback Interface
/// @notice Interface for onRate-callback implementation
interface IOnRateCallback is IRate {
    /// @notice Handle callback of rate call
    /// @param _rate Calculated rate or null if impossible to calculate
    /// @param _reserves Current pair's reserves
    /// @param _payload Any extra data from the previous call
    function onRateCallback(
        optional(Rate) _rate,
        uint128[] _reserves,
        TvmCell _payload
    ) external;
}
