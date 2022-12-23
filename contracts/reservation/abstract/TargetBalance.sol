pragma ever-solidity >= 0.61.2;

import "../../libraries/UtilityFlag.sol";

import "../interfaces/ITargetBalance.sol";

/// @author Alexander Kunekov
/// @title Target Balance
/// @notice Implements base functions for contract with target balance
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract TargetBalance is ITargetBalance {
    /// @dev Internal call to get target balance
    /// @dev Should be implemented by developer
    /// @return uint128 Balance to keep on the contract
    function _getTargetBalanceInternal()
        internal
        view
        virtual
        returns (uint128);

    function getTargetBalance()
        external
        view
        override
        responsible
        returns (uint128)
    {
        return {
            value: 0,
            flag: UtilityFlag.REMAINING_GAS,
            bounce: false
        } _getTargetBalanceInternal();
    }
}
