pragma ton-solidity >= 0.57.1;

/// @title OnRate-callback Interface
/// @notice Interface for onRate-callback implementation
interface IOnSuccessPriceCallback {
    /// @notice Handle callback of rate call
    /// @param _prices Calculated rate or null if impossible to calculate
    /// @param _timestamp Current pair's reserves
    /// @param _payload Any extra data from the previous call
    function onSuccessPriceCallback(
        mapping(address => uint) _prices,
        uint64 _timestamp,
        address _sender,
        TvmCell _payload
    ) external;
}
