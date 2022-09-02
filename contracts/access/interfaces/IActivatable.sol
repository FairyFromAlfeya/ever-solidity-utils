pragma ton-solidity >= 0.57.1;

interface IActivatable {
    event ActiveChanged(
        bool current,
        bool previous
    );

    function getActive() external view responsible returns (bool);

    function setActive(
        bool _newActive,
        optional(address) _remainingGasTo
    ) external;
}
