pragma ever-solidity >= 0.63.0;

/// @author Alexander Kunekov
/// @title Activatable Interface
/// @notice Interface for interaction with activatable contract
interface IActivatable {
    /// @notice Emits when the contract's active status is changed
    /// @dev Should be emitted only inside _setActiveStatusInternal()
    event ActiveStatusChanged(
        bool current,
        bool previous
    );

    /// @notice Get the current active status of the contract
    /// @return bool Status
    function getActiveStatus() external view responsible returns (bool);

    /// @notice Sets new active status for the contract
    /// @dev Only the current owner can perform. See Ownable contract
    /// @param _newActiveStatus New active status
    /// @param _remainingGasTo Gas recipient
    function setActiveStatus(
        bool _newActiveStatus,
        optional(address) _remainingGasTo
    ) external;
}
