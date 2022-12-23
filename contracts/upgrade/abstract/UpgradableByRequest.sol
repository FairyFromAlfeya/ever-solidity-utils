pragma ever-solidity >= 0.61.2;

import "../../libraries/UtilityErrors.sol";
import "../../libraries/UtilityFlag.sol";

import "../../reservation/abstract/Reservable.sol";
import "../../reservation/abstract/TargetBalance.sol";

import "../../validation/abstract/Validatable.sol";

import "../interfaces/IUpgradableByRequest.sol";
import "../interfaces/IUpgrader.sol";

import "./Version.sol";

/// @author Alexander Kunekov
/// @title Upgradable by Request
/// @notice Implements base functions for upgradable by request contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract UpgradableByRequest is
    IUpgradableByRequest,
    Reservable,
    Validatable,
    Version,
    TargetBalance
{
    /// @dev Current contract's upgrader
    address private _upgrader;

    function _getTargetBalanceInternal()
        internal
        virtual
        override
        view
        returns (uint128);

    /// @dev Only upgrader can call function with this modifier
    modifier onlyUpgrader() {
        require(
            _upgrader.value != 0 &&
            msg.sender == _upgrader,
            UtilityErrors.CALLER_IS_NOT_UPGRADER
        );
        _;
    }

    function getUpgrader()
        external
        view
        override
        responsible
        returns (address)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } _upgrader;
    }

    function requestUpgrade(optional(address) _remainingGasTo)
        external
        view
        override
        reserve(_getTargetBalanceInternal())
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Gas recipient from params or default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        IUpgrader(_upgrader)
            .provideUpgrade{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false
            }(
                _getCurrentVersionInternal(),
                _getDeployParamsInternal(),
                remainingGasTo
            );
    }

    /// @dev Internal call to set new upgrader
    /// @dev Emits UpgraderChanged event after update
    /// @param _newUpgrader New upgrader
    function _setUpgraderInternal(address _newUpgrader) internal {
        address previous = _upgrader;
        _upgrader = _newUpgrader;

        emit UpgraderChanged(
            _newUpgrader,
            previous
        );
    }

    /// @dev Use it inside onCodeUpgrade to set upgrader without UpgraderChanged event
    /// @param _newUpgrader New upgrader
    function _setUpgraderSilent(address _newUpgrader) internal {
        _upgrader = _newUpgrader;
    }

    /// @dev Internal call to get contract's upgrader
    /// @dev Useful for contract upgrading to remember upgrader
    /// @return address Current contract's upgrader
    function _getUpgraderInternal() internal view returns (address) {
        return _upgrader;
    }

    /// @dev Get params which was used for contract's deploy
    /// @dev Should be implemented by developer
    /// @return TvmCell Encoded deploy params
    function _getDeployParamsInternal()
        internal
        view
        virtual
        returns (TvmCell);
}
