pragma ton-solidity >= 0.57.1;

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
}
