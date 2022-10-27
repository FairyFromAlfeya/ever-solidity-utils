pragma ever-solidity >= 0.63.0;

/// @author Alexander Kunekov
/// @title Utility Errors
/// @notice Possible errors when interacting with utility contracts
library UtilityErrors {
    /// @dev Caller must be owner of the contract
    uint16 constant CALLER_IS_NOT_OWNER = 1000;

    /// @dev Address of the new owner is not valid
    uint16 constant INVALID_NEW_OWNER = 1001;

    /// @dev Address of the gas recipient is not valid
    uint16 constant INVALID_GAS_RECIPIENT = 1002;

    /// @dev Contract is not active
    uint16 constant CONTRACT_IS_NOT_ACTIVE = 1003;

    /// @dev TvmCell with contract's new code is empty
    uint16 constant INVALID_CODE = 1004;

    /// @dev Platform code can not be set twice
    uint16 constant PLATFORM_CODE_ALREADY_SET = 1005;

    /// @dev Specified address is nil or equals contract
    uint16 constant INVALID_ADDRESS = 1006;

    /// @dev Caller must be upgrader of the contract
    uint16 constant CALLER_IS_NOT_UPGRADER = 1007;

    /// @dev Caller must be instance of the factory
    uint16 constant CALLER_IS_NOT_INSTANCE = 1008;

    /// @dev TvmCell with deploy params is empty
    uint16 constant INVALID_DEPLOY_PARAMS = 1009;
}
