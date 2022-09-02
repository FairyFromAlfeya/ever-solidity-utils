pragma ton-solidity >= 0.57.1;

/// @title Activatable Interface
/// @notice Interface for interaction with activatable contract
interface IActivatable {
    /// @dev Emits when contract's active status was changed
    event ActiveChanged(
        bool current,
        bool previous
    );

    /// @notice Get the current contract's active status
    /// @return bool Status
    function getActive() external view responsible returns (bool);

    /// @notice Sets new contract's active status
    /// @dev Only the current owner can perform
    /// @param _newActive New active status
    /// @param _remainingGasTo Gas recipient
    function setActive(
        bool _newActive,
        optional(address) _remainingGasTo
    ) external;
}
