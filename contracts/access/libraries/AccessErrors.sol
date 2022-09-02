pragma ton-solidity >= 0.57.1;

library AccessErrors {
    uint16 constant CALLER_IS_NOT_OWNER = 200;
    uint16 constant INVALID_NEW_OWNER = 201;
    uint16 constant INVALID_GAS_RECIPIENT = 202;
}
