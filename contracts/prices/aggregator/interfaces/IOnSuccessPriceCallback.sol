pragma ever-solidity >= 0.61.2;

/// @author Alexander Kunekov
/// @title OnSuccessPrice-callback Interface
/// @notice Interface for onSuccessPrice-callback implementation
interface IOnSuccessPriceCallback {
    /// @notice Success callback from getPrices call with prices
    /// @param _prices Aggregated rates
    /// @param _scales Difference between token and aggregator's reference decimals:
    ///                Price from _prices: 1 satoshi = 200 µUSDT
    ///                Price in base units: 1 BTC = price * 10 ^ scale = 20000 USDT
    /// @param _expireAt When will prices expire
    /// @param _sender Who requested prices
    /// @param _payload Extra user-defined data from getPrices request
    function onSuccessPriceCallback(
        mapping(address => uint) _prices,
        mapping(address => int16) _scales,
        uint64 _expireAt,
        address _sender,
        TvmCell _payload
    ) external;
}
