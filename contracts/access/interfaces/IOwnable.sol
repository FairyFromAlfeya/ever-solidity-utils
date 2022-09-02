pragma ton-solidity >= 0.57.1;

/// @title Ownable Interface
/// @notice Interface for interaction with ownable contract
interface IOwnable {
    /// @dev Emits when contract's owner was changed
    event OwnerChanged(
        address current,
        address previous
    );

    /// @notice Get the current contract's owner
    /// @return address Owner's address
    function getOwner() external view responsible returns (address);

    /// @notice Sets new contract's owner
    /// @dev Only the current owner can perform
    /// @param _newOwner Address of the new owner
    /// @param _remainingGasTo Gas recipient
    function setOwner(
        address _newOwner,
        optional(address) _remainingGasTo
    ) external;
}
