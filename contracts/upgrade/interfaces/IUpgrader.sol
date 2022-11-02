pragma ever-solidity >= 0.63.0;

/// @author Alexander Kunekov
/// @title Upgrader Interface
/// @notice Interface for upgrader-contract implementation
interface IUpgrader {
    /// @notice Upgrades child contract's code
    /// @dev Only the child contract can call
    /// @param _instanceVersion Version of the contract which request upgrade
    /// @param _deployParams Packed params which was used for deploy
    /// @param _remainingGasTo Gas recipient
    function provideUpgrade(
        uint32 _instanceVersion,
        TvmCell _deployParams,
        address _remainingGasTo
    ) external view;
}
