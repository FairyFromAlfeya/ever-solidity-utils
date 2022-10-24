pragma ton-solidity >= 0.57.1;

/// @title Upgrader Interface
/// @notice Interface for upgrader-contract implementation
interface IUpgrader {
    /// @notice Upgrades child contract's code
    /// @dev Only the child contract can call
    /// @param _currentVersion Version of the contract which request upgrade
    /// @param _params Deploy params
    /// @param _remainingGasTo Gas recipient
    function provideUpgrade(
        uint32 _currentVersion,
        TvmCell _params,
        address _remainingGasTo
    ) external view;
}
