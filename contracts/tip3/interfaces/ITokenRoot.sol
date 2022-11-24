pragma ever-solidity >= 0.61.2;

/// @author Broxus Team
/// @title Token Root Interface
/// @notice Interface for interaction with TokenRoot contract
interface ITokenRoot {
    /// @notice Get name of the token
    /// @return string Token's name
    function name() external view responsible returns (string);

    /// @notice Get symbol of the token
    /// @return string Token's symbol
    function symbol() external view responsible returns (string);

    /// @notice Get decimals of the token
    /// @return uint8 Token's decimals
    function decimals() external view responsible returns (uint8);

    /// @notice Get total supply of tokens
    /// @return uint128 Total supply
    function totalSupply() external view responsible returns (uint128);

    /// @notice Get current owner
    /// @return address Root's owner
    function rootOwner() external view responsible returns (address);

    /// @notice Derive TokenWallet address from owner address
    /// @param _owner Owner's address
    /// @return address TokenWallet address
    function walletOf(address _owner) external view responsible returns (address);

    /// @notice Deploy new TokenWallet
    /// @dev Can be called by anyone
    /// @param _owner Token wallet owner address
    /// @param _deployWalletValue Gas value to
    function deployWallet(
        address _owner,
        uint128 _deployWalletValue
    ) external responsible returns (address);
}
