pragma ever-solidity >= 0.63.0;

/// @author Alexander Kunekov
/// @title Version Interface
/// @notice Interface for versioned contract implementation
interface IVersion {
    /// @dev Emits when the contract was successfully upgraded
    event VersionChanged(
        uint32 current,
        uint32 previous
    );

    /// @notice Get the current contract's version
    /// @return uint32 Contract's version
    function getVersion() external view responsible returns (uint32);

    /// @notice Get the previous contract's version
    /// @return uint32 Contract's previous version
    function getPreviousVersion() external view responsible returns (uint32);
}
