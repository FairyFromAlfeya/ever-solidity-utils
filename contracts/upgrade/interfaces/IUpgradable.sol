pragma ever-solidity >= 0.63.0;

/// @author Alexander Kunekov
/// @title Upgradable Interface
/// @notice Interface for contract upgrade implementation
interface IUpgradable {
    /// @notice Upgrades contract's code
    /// @dev Only the owner can perform. See Ownable
    /// @dev Should be implemented by developer
    /// @param _code Contract's new code
    /// @param _remainingGasTo Gas recipient
    function upgrade(
        TvmCell _code,
        optional(address) _remainingGasTo
    ) external;
}
