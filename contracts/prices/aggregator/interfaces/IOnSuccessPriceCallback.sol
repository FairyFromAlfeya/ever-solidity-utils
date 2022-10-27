pragma ever-solidity >= 0.63.0;

/// @author Alexander Kunekov
/// @title OnSuccessPrice-callback Interface
/// @notice Interface for onSuccessPrice-callback implementation
interface IOnSuccessPriceCallback {
    /// @notice Success callback from getPrices call with prices
    /// @param _prices Aggregated rates
    /// @param _scales Difference between token and aggregator's reference decimals:
    ///                Price from _prices: 1 satoshi = 200 µUSDT
    ///                Price in base units: 1 BTC = price * 10 ^ scale = 20000 USDT
    /// @param _timestamp When callback was sent
    /// @param _sender Who requested prices
    /// @param _payload Extra user-defined data from getPrices request
    function onSuccessPriceCallback(
        mapping(address => uint) _prices,
        mapping(address => int16) _scales,
        uint64 _timestamp,
        address _sender,
        TvmCell _payload
    ) external;
}
