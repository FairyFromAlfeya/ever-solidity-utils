pragma ton-solidity >= 0.57.1;

/// @title Factory Interface
/// @notice Interface for interaction with factory contract
interface IFactory {
    /// @dev Emits when factory deployed a new contract
    event InstanceDeployed(
        address instance,
        uint32 version,
        address deployer
    );

    /// @dev Emits when instance's code was changed
    event InstanceVersionChanged(
        uint32 current,
        uint32 previous
    );

    /// @notice Get the current instance's code
    /// @return TvmCell Instance's code
    function getInstanceCode() external view responsible returns (TvmCell);

    /// @notice Get the current instance's code version
    /// @return bool Instance's code version
    function getInstanceVersion() external view responsible returns (uint32);

    /// @notice Get instance address by deploy params
    /// @param _params Deploy params
    /// @return address Expected instance's address
    function getInstanceAddress(TvmCell _params) external view responsible returns (address);

    /// @notice Sets new instance's code
    /// @dev Only the current owner can perform
    /// @param _newCode New instance's code
    /// @param _remainingGasTo Gas recipient
    function setInstanceCode(
        TvmCell _newCode,
        optional(address) _remainingGasTo
    ) external;

    /// @notice Deploys new instance with specified params
    /// @param _params Parameters for the new contract to deploy
    /// @param _remainingGasTo Gas recipient
    function deploy(
        TvmCell _params,
        optional(address) _remainingGasTo
    ) external;
}
