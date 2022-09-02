pragma ton-solidity >= 0.57.1;

interface IOwnable {
    event OwnerChanged(address current, address previous);

    function getOwner() external view responsible returns (address);

    function setOwner(
        address _newOwner,
        optional(address) _remainingGasTo
    ) external;
}
