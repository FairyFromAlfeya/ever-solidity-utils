pragma ton-solidity >= 0.57.1;

library Validation {
    function notEquals(
        address _a,
        address _b,
        uint16 _error
    ) public {
        require(_a.value != 0 && _a != _b, _error);
    }

    function notEmpty(
        TvmCell _a,
        uint16 _error
    ) public {
        require(!_a.toSlice().empty(), _error);
    }
}
