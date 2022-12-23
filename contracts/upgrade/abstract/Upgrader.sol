pragma ever-solidity >= 0.61.2;

import "../../libraries/UtilityErrors.sol";
import "../../libraries/UtilityFlag.sol";

import "../../reservation/abstract/Reservable.sol";
import "../../reservation/abstract/TargetBalance.sol";

import "../../validation/abstract/Validatable.sol";

import "../interfaces/IUpgradableByRequest.sol";
import "../interfaces/IUpgrader.sol";

/// @author Alexander Kunekov
/// @title Upgrader
/// @notice Implements base functions for upgrader-contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Upgrader is
    IUpgrader,
    Reservable,
    Validatable,
    TargetBalance
{
    function _getTargetBalanceInternal()
        internal
        virtual
        override
        view
        returns (uint128);

    function provideUpgrade(
        uint32 _instanceVersion,
        TvmCell _deployParams,
        address _remainingGasTo
    )
        external
        view
        virtual
        override
        reserve(_getTargetBalanceInternal())
        validTvmCell(_deployParams, UtilityErrors.INVALID_DEPLOY_PARAMS)
        validAddress(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        require(
            _getInstanceAddressInternal(_deployParams) == msg.sender,
            UtilityErrors.CALLER_IS_NOT_INSTANCE
        );

        (uint32 version, TvmCell code) = _getParamsForUpgradeInternal();

        // Upgrade to last version if contract's version is different
        if (_instanceVersion != version) {
            IUpgradableByRequest(msg.sender)
                .upgrade{
                    value: 0,
                    flag: UtilityFlag.ALL_NOT_RESERVED,
                    bounce: false
                }(
                    version,
                    code,
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

    /// @dev Internal call to get instance address by specified deploy params
    /// @dev Should be implemented by developer
    /// @param _deployParams Packed params which was used for deploy
    /// @return address Expected instance's address
    function _getInstanceAddressInternal(TvmCell _deployParams)
        internal
        view
        virtual
        returns (address);

    /// @dev Internal call to get last code and version for instance
    /// @dev Should be implemented by developer
    /// @return (uint32, TvmCell) Last version and code
    function _getParamsForUpgradeInternal()
        internal
        view
        virtual
        returns (uint32, TvmCell);
}
