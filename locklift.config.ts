import { LockliftConfig } from 'locklift';
import { FactorySource } from './build/factorySource';
import { SimpleGiver } from './giver';

declare global {
  const locklift: import('locklift').Locklift<FactorySource>;
}

const LOCAL_NETWORK_ENDPOINT = 'http://localhost/graphql';

const config: LockliftConfig = {
  compiler: { version: '0.63.0' },
  linker: { version: '0.18.4' },
  networks: {
    local: {
      connection: {
        id: 1337,
        group: 'localnet',
        type: 'graphql',
        data: {
          endpoints: [LOCAL_NETWORK_ENDPOINT],
          latencyDetectionInterval: 1000,
          local: true,
        },
      },
      giver: {
        giverFactory: (ever, keyPair, address) =>
          new SimpleGiver(ever, keyPair, address),
        address:
          '0:ece57bcc6c530283becbbd8a3b24d3c5987cdddc3c8b7b33be6e4a6312490415',
        key: '172af540e43a524763dd53b26a066d472a97c4de37d5498170564510608250c3',
      },
      tracing: { endpoint: LOCAL_NETWORK_ENDPOINT },
      keys: {
        phrase:
          'action inject penalty envelope rabbit element slim tornado dinner pizza off blood',
        amount: 20,
      },
    },
  },
  mocha: { timeout: 2000000 },
};

export default config;
