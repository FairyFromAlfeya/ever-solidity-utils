pragma ever-solidity >= 0.63.0;

/// @author Alexander Kunekov
/// @title Factory Interface
/// @notice Interface for interaction with factory contract
interface IFactory {
    /// @notice Emits when factory deployed a new contract
    /// @dev Should be emitted only inside deploy()
    /// @param instance Address of the deployed instance
    /// @param version Version of the deployed instance
    /// @param deployer Deployer of the instance
    event InstanceDeployed(
        address instance,
        uint32 version,
        address deployer
    );

    /// @notice Emits when instance's code is changed
    /// @dev Should be emitted only inside _setInstanceCodeInternal()
    event InstanceVersionChanged(
        uint32 current,
        uint32 previous
    );

    /// @notice Get the current instance's code
    /// @return TvmCell Code of the instance
    function getInstanceCode() external view responsible returns (TvmCell);

    /// @notice Get the current instance's version
    /// @return uint32 Version of the instance
    function getInstanceVersion() external view responsible returns (uint32);

    /// @notice Get instance address by deploy params
    /// @param _deployParams Packed deploy params
    /// @return address Expected instance's address
    function getInstanceAddress(TvmCell _deployParams) external view responsible returns (address);

    /// @notice Sets new instance's code
    /// @dev Only the current owner can perform. See Ownable contract
    /// @param _newInstanceCode New instance's code
    /// @param _remainingGasTo Gas recipient
    function setInstanceCode(
        TvmCell _newInstanceCode,
        optional(address) _remainingGasTo
    ) external;

    /// @notice Deploys a new instance with specified params
    /// @dev Should be implemented by developer
    /// @param _deployParams Packed params for the new contract to deploy
    /// @param _remainingGasTo Gas recipient
    function deploy(
        TvmCell _deployParams,
        optional(address) _remainingGasTo
    ) external;
}
