pragma ever-solidity >= 0.63.0;

/// @author Broxus Team
/// @title Token Wallet Interface
/// @notice Interface for interaction with TokenWallet contract
interface ITokenWallet {
    /// @notice Get wallet's TokenRoot
    /// @return address Wallet's TokenRoot address
    function root() external view responsible returns (address);

    /// @notice Get wallet's balance
    /// @return uint128 Wallet's balance
    function balance() external view responsible returns (uint128);

    /// @notice Get owner's address
    /// @return address Wallet's owner
    function owner() external view responsible returns (address);

    /// @notice Transfer tokens and optionally deploys TokenWallet for recipient
    /// @dev Only the owner can perform
    /// @param _amount How much tokens to transfer
    /// @param _recipient Tokens recipient
    /// @param _deployWalletValue EVER amount for new wallet deploy
    /// @param _remainingGasTo Gas recipient
    /// @param _notify Whether or not notify recipient about transfer
    /// @param _payload Payload for onAcceptTokensTransfer-callback
    function transfer(
        uint128 _amount,
        address _recipient,
        uint128 _deployWalletValue,
        address _remainingGasTo,
        bool _notify,
        TvmCell _payload
    ) external;

    /// @notice Transfer tokens using another TokenWallet address, that wallet must be deployed previously
    /// @dev Only the owner can perform
    /// @param _amount How much tokens to transfer
    /// @param _recipientWallet Recipient TokenWallet address
    /// @param _remainingGasTo Gas recipient
    /// @param _notify Whether or not notify recipient about transfer
    /// @param _payload Payload for onAcceptTokensTransfer-callback
    function transferToWallet(
        uint128 _amount,
        address _recipientWallet,
        address _remainingGasTo,
        bool _notify,
        TvmCell _payload
    ) external;
}
