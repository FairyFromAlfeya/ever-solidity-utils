pragma ever-solidity >= 0.61.2;

/// @author Alexander Kunekov
/// @title Target Balance Interface
/// @notice Interface for interaction with contract with target balance
interface ITargetBalance {
    /// @notice Get the target balance of the contract
    /// @return uint128 Balance which keeps on the contract
    function getTargetBalance() external view responsible returns (uint128);
}
