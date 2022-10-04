pragma ton-solidity >= 0.57.1;

import "../interfaces/IUpgradable.sol";

import "./Version.sol";

/// @title Upgradable
/// @notice Implements base functions for upgradable contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Upgradable is Version, IUpgradable {}
