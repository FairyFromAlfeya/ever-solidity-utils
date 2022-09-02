pragma ton-solidity >= 0.57.1;

interface IUpgradable {
    event VersionChanged(
        uint32 current,
        uint32 previous
    );

    function upgrade(
        TvmCell _code,
        optional(address) _remainingGasTo
    ) external;
}
