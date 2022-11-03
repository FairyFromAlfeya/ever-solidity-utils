import { Address, Contract, WalletTypes, lockliftChai } from 'locklift';
import { FactorySource } from '../build/factorySource';
import chai, { expect } from 'chai';
import { OracleObservations, TvmCellWithSigner0 } from './contants';

chai.use(lockliftChai);

describe('PriceOracle', () => {
  let address: Address;
  let oracleExample: Contract<FactorySource['TWAPOracleExample']>;
  let callbacksExample: Contract<FactorySource['TWAPOracleCallbacksExample']>;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract: exampleOracle } = await locklift.factory.deployContract({
      contract: 'TWAPOracleExample',
      publicKey: signer.publicKey,
      initParams: { _nonce: locklift.utils.getRandomNonce() },
      constructorParams: { _remainingGasTo: address },
      value: locklift.utils.toNano(10),
    });

    const { contract: exampleCallbacks } =
      await locklift.factory.deployContract({
        contract: 'TWAPOracleCallbacksExample',
        publicKey: signer.publicKey,
        initParams: {
          _nonce: locklift.utils.getRandomNonce(),
          _oracle: exampleOracle.address,
        },
        constructorParams: { _remainingGasTo: address },
        value: locklift.utils.toNano(10),
      });

    oracleExample = exampleOracle;
    callbacksExample = exampleCallbacks;
  });

  describe('set observations', () => {
    it('set observation 1', async () => {
      const { traceTree } = await locklift.tracing.trace(
        oracleExample.methods
          .setObservation({
            _observation: OracleObservations[0],
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('setObservation')
        .count(1)
        .withNamedArgs({
          _observation: OracleObservations[0],
          _remainingGasTo: address,
        })
        .and.to.emit('OracleUpdated')
        .count(1)
        .withNamedArgs({
          value0: OracleObservations[0],
        });
    });

    it('set observation 2', async () => {
      const { traceTree } = await locklift.tracing.trace(
        oracleExample.methods
          .setObservation({
            _observation: OracleObservations[1],
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('setObservation')
        .count(1)
        .withNamedArgs({
          _observation: OracleObservations[1],
          _remainingGasTo: address,
        })
        .and.to.emit('OracleUpdated')
        .count(1)
        .withNamedArgs({
          value0: OracleObservations[1],
        });
    });
  });

  describe('check callbacks', () => {
    it('should return on observation callback', async () => {
      const { traceTree } = await locklift.tracing.trace(
        callbacksExample.methods
          .observation({
            _timestamp: OracleObservations[0].timestamp,
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('observation')
        .count(2)
        .and.to.call('onObservationCallback')
        .count(1)
        .withNamedArgs({
          _observation: OracleObservations[0],
          _payload: TvmCellWithSigner0,
        });
    });

    it('should return on rate callback', async () => {
      const { traceTree } = await locklift.tracing.trace(
        callbacksExample.methods
          .rate({
            _fromTimestamp: OracleObservations[0].timestamp,
            _toTimestamp: OracleObservations[1].timestamp,
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('rate')
        .count(2)
        .and.to.call('onRateCallback')
        .count(1)
        .withNamedArgs({
          _rate: {
            price0To1: '6168503981945532210312338382359',
            price1To0: '18771502713822619963335681409632413161332752969',
            fromTimestamp: OracleObservations[0].timestamp,
            toTimestamp: OracleObservations[1].timestamp,
          },
          _payload: TvmCellWithSigner0,
        });
    });
  });
});
