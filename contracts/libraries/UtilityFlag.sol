pragma ever-solidity >= 0.63.0;

/// @author Broxus Team
/// @title Utility Flag
/// @notice Possible flags when sending message from contract
library UtilityFlag {
    /// @dev Contract will be charged for message creation
    uint8 constant SENDER_PAYS_FEES = 1;

    /// @dev Send message even after errors in contract
    uint8 constant IGNORE_ERRORS = 2;

    /// @dev Destroy contract if its balance after sending will be zero
    uint8 constant DESTROY_IF_ZERO = 32;

    /// @dev Use credit gas only
    uint8 constant REMAINING_GAS = 64;

    /// @dev Send all balance which wasn't reserve
    uint8 constant ALL_NOT_RESERVED = 128;
}
