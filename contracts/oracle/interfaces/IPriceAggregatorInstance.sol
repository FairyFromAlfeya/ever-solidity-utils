pragma ton-solidity >= 0.57.1;

/// @title Price Aggregator Instance Interface
/// @notice Interface for interaction with price aggregator
interface IPriceAggregatorInstance {
    /// @notice Get prices for requested tokens
    /// @dev Only whitelisted tokens are allowed
    /// @param _tokens Tokens addresses
    /// @param _recipient Callback recipient
    /// @param _remainingGasTo Gas recipient
    /// @param _payload Payload for request
    function getPrice(
        address[] _tokens,
        address _recipient,
        bool _proxy,
        address _remainingGasTo,
        TvmCell _payload
    ) external;
}
