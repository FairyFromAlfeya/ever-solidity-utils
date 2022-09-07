pragma ton-solidity >= 0.57.1;

/// @title Utility Errors
/// @notice Possible errors when interacting with utility contracts
library UtilityErrors {
    /// @dev Caller must be owner of the contract
    uint16 constant CALLER_IS_NOT_OWNER = 200;

    /// @dev Address of the new owner is not valid
    uint16 constant INVALID_NEW_OWNER = 201;

    /// @dev Address of the gas recipient is not valid
    uint16 constant INVALID_GAS_RECIPIENT = 202;

    /// @dev Contract is not active
    uint16 constant CONTRACT_IS_NOT_ACTIVE = 203;

    /// @dev TvmCell with contract's new code is empty
    uint16 constant INVALID_CODE = 204;

    /// @dev Platform code can not be set twice
    uint16 constant PLATFORM_CODE_ALREADY_SET = 205;
}
