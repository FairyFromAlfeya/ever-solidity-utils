pragma ton-solidity >= 0.57.1;

import "../../libraries/UtilityErrors.sol";
import "../../libraries/UtilityFlag.sol";
import "../../libraries/UtilityGas.sol";

import "../../validation/abstract/Validatable.sol";

import "../interfaces/IUpgradableByRequest.sol";
import "../interfaces/IUpgrader.sol";

import "./Version.sol";

/// @title Upgradable by Request
/// @notice Implements base functions for upgradable by request contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract UpgradableByRequest is
    Version,
    Validatable,
    IUpgradableByRequest
{
    /// @dev Current contract's upgrader
    address private _upgrader;

    /// @dev Only upgrader can call function with this modifier
    modifier onlyUpgrader() {
        require(
            _upgrader.value != 0 &&
            msg.sender == _upgrader,
            UtilityErrors.CALLER_IS_NOT_UPGRADER
        );
        _;
    }

    /// @dev Get params which was used for contract's deploy
    /// @return TvmCell Encoded deploy params
    function _getDeployParamsInternal() internal view virtual returns (TvmCell);

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
        } _getUpgraderInternal();
    }

    function requestUpgrade(optional(address) _remainingGasTo)
        external
        view
        override
        reserve(UtilityGas.INITIAL_BALANCE)
        validAddressOrNull(_remainingGasTo, UtilityErrors.INVALID_GAS_RECIPIENT)
    {
        // Gas recipient from params or default
        address remainingGasTo = _remainingGasTo.hasValue() ? _remainingGasTo.get() : msg.sender;

        IUpgrader(_getUpgraderInternal())
            .requestUpgrade{
                value: 0,
                flag: UtilityFlag.ALL_NOT_RESERVED,
                bounce: false
            }(
                _getVersionInternal(),
                _getDeployParamsInternal(),
                remainingGasTo
            );
    }

    /// @dev Internal call to set new upgrader
    /// @param _newUpgrader New upgrader
    function _setUpgraderInternal(address _newUpgrader) internal {
        address previous = _upgrader;
        _upgrader = _newUpgrader;

        emit UpgraderChanged(
            _newUpgrader,
            previous
        );
    }

    /// @dev Internal call to get contract's upgrader
    /// @return address Current contract's upgrader
    function _getUpgraderInternal() internal view returns (address) {
        return _upgrader;
    }
}
