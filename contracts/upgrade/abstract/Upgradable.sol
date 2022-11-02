pragma ever-solidity >= 0.63.0;

import "../interfaces/IUpgradable.sol";

import "./Version.sol";

/// @author Alexander Kunekov
/// @title Upgradable
/// @notice Implements base functions for upgradable contract
/// @dev A contract is abstract - to be sure that it will be inherited by another contract
abstract contract Upgradable is IUpgradable, Version {}
