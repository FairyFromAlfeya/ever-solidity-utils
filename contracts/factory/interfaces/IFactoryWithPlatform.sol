pragma ton-solidity >= 0.57.1;

import "./IFactory.sol";

/// @title Factory with Platform Interface
/// @notice Interface for interaction with factory with platform contract
interface IFactoryWithPlatform is IFactory {
    /// @dev Emits when platform's code was set
    event PlatformCodeSet();

    /// @notice Get the current platform's code
    /// @return TvmCell Platform's code
    function getPlatformCode() external view responsible returns (TvmCell);

    /// @notice Sets new platform's code
    /// @dev Only the current owner can perform
    /// @param _newCode New platform's code
    /// @param _remainingGasTo Gas recipient
    function setPlatformCode(
        TvmCell _newCode,
        optional(address) _remainingGasTo
    ) external;
}
