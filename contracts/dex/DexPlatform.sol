pragma ton-solidity >= 0.57.0;

pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

/// @title DEX Platform
/// @notice Implements base functions for factory contract
/// @dev Use this contract only for tvm.buildStateInit
contract DexPlatform {
    /// @dev Address of the DEX root
    address static root;

    /// @dev Type of the instance (account or pair)
    uint8 static type_id;

    /// @dev Deploy params
    TvmCell static params;

    /// @dev Platform constructor
    /// @param _code Instance code
    /// @param _version Code's version
    /// @param _vault DEX vault address
    /// @param _remainingGasTo Gas recipient
    constructor(
        TvmCell _code,
        uint32 _version,
        address _vault,
        address _remainingGasTo
    ) public {}
}
