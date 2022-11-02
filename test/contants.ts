import { Address } from 'locklift';

export const DexRoot = new Address(
  '0:5eb5713ea9b4a0f3a13bc91b282cde809636eb1e68d2fcb6427b9ad78a5a9008',
);

export const DaiTokenRoot = new Address(
  '0:eb2ccad2020d9af9cec137d3146dde067039965c13a27d97293c931dae22b2b9',
);

export const WeverTokenRoot = new Address(
  '0:a49cd4e158a9a15555e624759e2e4e766d22600b7800d891e46f9291f044a93d',
);

export const DaiWeverPair = new Address(
  '0:f0120fdea2a4e1977f627caae480b8ba9afa4d76296a014050e8a584f710ff06',
);

export const TvmCellWithSigner0 =
  'te6ccgEBAQEAJAAAQ4ABF9cak8BiVL3ozbA5hv/SnR6crr+dEIRt4kTka4cfJnA=';

export const EmptyTvmCell = 'te6ccgEBAQEAAgAAAA==';

export const TokenFoo = {
  name: 'Token Foo',
  symbol: 'FOO',
  decimals: '9',
};

type Observation = {
  timestamp: string;
  price0To1Cumulative: string;
  price1To0Cumulative: string;
};

export const OracleObservations: Observation[] = [
  {
    timestamp: '1667295657',
    price0To1Cumulative: '28489202304693639295750299703531321433',
    price1To0Cumulative:
      '123981749911335226382112413117960481545593152374194650',
  },
  {
    timestamp: '1667297337',
    price0To1Cumulative: '28499565391383307789863624432013686059',
    price1To0Cumulative:
      '124013286035894448383650817062728663999704191399183609',
  },
];
