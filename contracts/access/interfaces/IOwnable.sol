pragma ever-solidity >= 0.61.2;

/// @author Alexander Kunekov
/// @title Ownable Interface
/// @notice Interface for interaction with ownable contract
interface IOwnable {
    /// @notice Emits when the contract's owner is changed
    /// @dev Should be emitted only inside _setOwnerInternal()
    event OwnerChanged(
        address current,
        address previous
    );

    /// @notice Get the current owner of the contract
    /// @return address Owner's address
    function getOwner() external view responsible returns (address);

    /// @notice Sets new owner for the contract
    /// @dev Only the current owner can perform
    /// @param _newOwner Address of the new owner
    /// @param _remainingGasTo Gas recipient
    function setOwner(
        address _newOwner,
        optional(address) _remainingGasTo
    ) external;
}
