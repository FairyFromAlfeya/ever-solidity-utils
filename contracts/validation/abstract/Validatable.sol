pragma ton-solidity >= 0.57.1;

import "../libraries/Validation.sol";

abstract contract Validatable {
    modifier validAddress(
        address _a,
        uint16 _error
    ) {
        Validation.notEquals(
            _a,
            address(this),
            _error
        );
        _;
    }

    modifier validTvmCell(
        TvmCell _a,
        uint16 _error
    ) {
        Validation.notEmpty(
            _a,
            _error
        );
        _;
    }

    modifier validAddressOrNull(
        optional(address) _a,
        uint16 _error
    ) {
        if (_a.hasValue()) {
            Validation.notEquals(
                _a.get(),
                address(this),
                _error
            );
        }
        _;
    }
}
