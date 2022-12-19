pragma ever-solidity >= 0.61.2;

/// @author Alexander Kunekov
/// @title Price Aggregator Instance Interface
/// @notice Interface for interaction with price aggregator instance
interface IPriceAggregatorInstance {
    /// @notice Get prices for requested tokens
    /// @dev Only whitelisted tokens are allowed
    /// @param _tokens Tokens addresses
    /// @param _callbackRecipient Recipient of the success or canceled callback
    /// @param _remainingGasTo Gas recipient
    /// @param _payload Extra user-defined data to return in callback
    function getPrices(
        address[] _tokens,
        address _callbackRecipient,
        address _remainingGasTo,
        TvmCell _payload
    ) external;
}
