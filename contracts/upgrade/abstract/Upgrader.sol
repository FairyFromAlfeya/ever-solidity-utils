pragma ton-solidity >= 0.57.1;

import "../../libraries/UtilityErrors.sol";
import "../../libraries/UtilityFlag.sol";
import "../../libraries/UtilityGas.sol";

import "../../validation/abstract/Validatable.sol";

import "../interfaces/IUpgrader.sol";
import "../interfaces/IUpgradableByRequest.sol";

/// @title Upgrader
/// @notice Implements base functions for upgrader-contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Upgrader is Validatable, IUpgrader {
    /// @dev Only factory instance can call function with this modifier
    modifier onlyInstance(TvmCell _params) {
        require(
            msg.sender == _getInstanceAddressForUpgradeInternal(_params),
            UtilityErrors.CALLER_IS_NOT_INSTANCE
        );
        _;
    }

    /// @dev Get last instance code version
    /// @return uint32 Last code version
    function _getInstanceVersionForUpgradeInternal()
        internal
        view
        virtual
        returns (uint32);

    /// @dev Get last instance code
    /// @return TvmCell Last instance code
    function _getInstanceCodeForUpgradeInternal()
        internal
        view
        virtual
        returns (TvmCell);

    /// @dev Get instance's address by deploy params
    /// @param _params Deploy params
    /// @return address Calculated instance's address
    function _getInstanceAddressForUpgradeInternal(TvmCell _params)
        internal
        view
        virtual
        returns (address);

    function requestUpgrade(
        uint32 _currentVersion,
        TvmCell _params,
        address _remainingGasTo
    )
        external
        view
        override
        reserve(UtilityGas.INITIAL_BALANCE)
        validTvmCell(_params, UtilityErrors.INVALID_DEPLOY_PARAMS)
        onlyInstance(_params)
        validAddress(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Upgrade to last version if contract's version is different
        if (_currentVersion != _getInstanceVersionForUpgradeInternal()) {
            IUpgradableByRequest(msg.sender)
                .upgrade{
                    value: 0,
                    flag: UtilityFlag.ALL_NOT_RESERVED,
                    bounce: false
                }(
                    _getInstanceVersionForUpgradeInternal(),
                    _getInstanceCodeForUpgradeInternal(),
                    _remainingGasTo
                );
        } else {
            _remainingGasTo.transfer({
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED + UtilityFlag.IGNORE_ERRORS,
                bounce: false
            });
        }
    }
}
