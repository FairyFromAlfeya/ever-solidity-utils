pragma ton-solidity >= 0.57.1;

interface IUpgradable {
    function upgrade(TvmCell _code) external;
}
