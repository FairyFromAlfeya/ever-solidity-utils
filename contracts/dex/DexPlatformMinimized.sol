pragma ever-solidity >= 0.61.2;

/// @author Alexander Hramcov
/// @title DEX Platform
/// @notice Minimized DEX platform contract for addresses deriving
/// @dev Use this contract only for tvm.buildStateInit
contract DexPlatformMinimized {
    /// @dev Address of the DEX root
    address static root;

    /// @dev Type of the instance (account or pair). See DexPlatformTypes
    uint8 static type_id;

    /// @dev Specific params which depends on the contract's type
    /// @dev For account: cell(address). Where an address is owner of the account
    /// @dev For pool: cell(leftAddress, rightAddress). Where leftAddress < rightAddress
    ///      and addresses are the pool's token roots
    TvmCell static params;

    /// @dev Platform constructor. Upgrades platform to the _code under the hood
    /// @param _code Code of the instance for upgrade to
    /// @param _version Code's version of the instance
    /// @param _vault Vault's address of the DEX
    /// @param _remainingGasTo Gas recipient
    constructor(
        TvmCell _code,
        uint32 _version,
        address _vault,
        address _remainingGasTo
    ) public {}
}
