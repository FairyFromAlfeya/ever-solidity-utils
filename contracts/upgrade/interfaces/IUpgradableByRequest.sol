pragma ever-solidity >= 0.63.0;

/// @author Alexander Kunekov
/// @title Upgradable by Request Interface
/// @notice Interface for contract upgrade by request implementation
interface IUpgradableByRequest {
    /// @dev Emits when the contract's upgrader was changed
    event UpgraderChanged(
        address current,
        address previous
    );

    /// @notice Get the current contract's upgrader
    /// @return address Upgrader's address
    function getUpgrader() external view responsible returns (address);

    /// @dev Request contract upgrade from upgrader
    /// @param _remainingGasTo Gas recipient
    function requestUpgrade(optional(address) _remainingGasTo) external view;

    /// @notice Upgrades contract's code
    /// @dev Only the upgrader can perform
    /// @param _version New version of the contract
    /// @param _code Contract's new code
    /// @param _remainingGasTo Gas recipient
    function upgrade(
        uint32 _version,
        TvmCell _code,
        address _remainingGasTo
    ) external;
}
