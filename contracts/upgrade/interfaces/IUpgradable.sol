pragma ton-solidity >= 0.57.1;

/// @title Upgradable Interface
/// @notice Interface for contract upgrade implementation
interface IUpgradable {
    /// @dev Emits when the contract was successfully upgraded
    event VersionChanged(
        uint32 current,
        uint32 previous
    );

    /// @notice Upgrades contract's code
    /// @dev Only the owner can perform
    /// @param _code Contract's new code
    /// @param _remainingGasTo Gas recipient
    function upgrade(
        TvmCell _code,
        optional(address) _remainingGasTo
    ) external;
}
