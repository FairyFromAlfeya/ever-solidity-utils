pragma ever-solidity >= 0.63.0;

/// @author Alexander Kunekov
/// @title Price Aggregator Instance Interface
/// @notice Interface for interaction with price aggregator instance
interface IPriceAggregatorInstance {
    /// @notice Get prices for requested tokens
    /// @dev Only whitelisted tokens are allowed
    /// @param _tokens Tokens addresses
    /// @param _callbackRecipient Recipient of the success or canceled callback
    /// @param _proxy Whether or not proxy callback through instance
    ///               msg.sender is always price aggregator instance if true
    ///               msg.sender can be price aggregator request if false
    /// @param _remainingGasTo Gas recipient
    /// @param _payload Extra user-defined data to return in callback
    function getPrices(
        address[] _tokens,
        address _callbackRecipient,
        bool _proxy,
        address _remainingGasTo,
        TvmCell _payload
    ) external;
}
