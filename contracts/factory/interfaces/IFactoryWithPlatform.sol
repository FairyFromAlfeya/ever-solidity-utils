pragma ever-solidity >= 0.63.0;

import "./IFactory.sol";

/// @author Alexander Kunekov
/// @title Factory with Platform Interface
/// @notice Interface for interaction with factory with platform contract
interface IFactoryWithPlatform is IFactory {
    /// @notice Emits when platform's code is set
    /// @dev Should be emitted only once inside _setPlatformCodeInternal()
    event PlatformCodeSet();

    /// @notice Get the current platform's code
    /// @return TvmCell Code of the platform
    function getPlatformCode() external view responsible returns (TvmCell);

    /// @notice Sets new platform's code
    /// @dev Can be performed only once by owner. See Ownable contract
    /// @param _newPlatformCode New platform's code
    /// @param _remainingGasTo Gas recipient
    function setPlatformCode(
        TvmCell _newPlatformCode,
        optional(address) _remainingGasTo
    ) external;
}
