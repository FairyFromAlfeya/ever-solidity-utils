pragma ton-solidity >= 0.57.1;

/// @title OnRate-callback Interface
/// @notice Interface for onRate-callback implementation
interface IOnCanceledPriceCallback {
    /// @notice Handle callback of rate call
    /// @param _prices Calculated rate or null if impossible to calculate
    /// @param _failed Token addresses without price
    /// @param _timestamp Send timestamp
    /// @param _payload Any extra data from the previous call
    function onCanceledPriceCallback(
        mapping(address => uint) _prices,
        address[] _failed,
        uint64 _timestamp,
        address _sender,
        TvmCell _payload
    ) external;
}
