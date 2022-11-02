pragma ever-solidity >= 0.63.0;

/// @author Broxus Team
/// @title AcceptTokensTransfer-callback Interface
/// @notice Interface for acceptTokensTransfer-callback implementation
interface IAcceptTokensTransferCallback {
    /// @notice Callback from TokenWallet on receive tokens transfer
    /// @param _tokenRoot TokenRoot of received tokens
    /// @param _amount Received tokens amount
    /// @param _sender Sender TokenWallet owner address
    /// @param _senderWallet Sender TokenWallet address
    /// @param _remainingGasTo Address specified for receive remaining gas
    /// @param _payload Additional data attached to transfer by sender
    function onAcceptTokensTransfer(
        address _tokenRoot,
        uint128 _amount,
        address _sender,
        address _senderWallet,
        address _remainingGasTo,
        TvmCell _payload
    ) external;
}
