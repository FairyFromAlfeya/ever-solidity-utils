import {
  Address,
  WalletTypes,
  Contract,
  lockliftChai,
  zeroAddress,
} from 'locklift';
import chai, { expect } from 'chai';
import { FactorySource } from '../build/factorySource';
import { EmptyTvmCell } from './contants';

chai.use(lockliftChai);

describe('PriceAggregator', () => {
  let address: Address;
  let aggregatorExample: Contract<FactorySource['PriceAggregatorExample']>;
  let callbacksExample: Contract<
    FactorySource['PriceAggregatorCallbacksExample']
  >;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract: exampleAggregator } =
      await locklift.factory.deployContract({
        contract: 'PriceAggregatorExample',
        publicKey: signer.publicKey,
        initParams: { _nonce: locklift.utils.getRandomNonce() },
        constructorParams: { _remainingGasTo: address },
        value: locklift.utils.toNano(10),
      });

    const { contract: exampleCallbacks } =
      await locklift.factory.deployContract({
        contract: 'PriceAggregatorCallbacksExample',
        publicKey: signer.publicKey,
        initParams: { _nonce: locklift.utils.getRandomNonce() },
        constructorParams: { _remainingGasTo: address },
        value: locklift.utils.toNano(10),
      });

    aggregatorExample = exampleAggregator;
    callbacksExample = exampleCallbacks;
  });

  describe('set prices and scales', () => {
    it('should set address as price with scale 3', async () => {
      const { traceTree } = await locklift.tracing.trace(
        aggregatorExample.methods
          .setPriceAndScale({
            _token: address,
            _price: '1',
            _scale: '3',
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('setPriceAndScale')
        .count(1)
        .withNamedArgs({
          _token: address,
          _price: '1',
          _scale: '3',
          _remainingGasTo: address,
        });
    });
  });

  describe('callbacks', () => {
    it('should return on success price callback', async () => {
      const { traceTree } = await locklift.tracing.trace(
        aggregatorExample.methods
          .getPrices({
            _tokens: [address],
            _proxy: false,
            _callbackRecipient: callbacksExample.address,
            _payload: '',
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('getPrices')
        .count(1)
        .withNamedArgs({
          _tokens: [address],
          _proxy: false,
          _callbackRecipient: callbacksExample.address,
          _payload: EmptyTvmCell,
          _remainingGasTo: address,
        })
        .and.to.call('onSuccessPriceCallback')
        .count(1)
        .withNamedArgs({
          _prices: [[address, '1']],
          _scales: [[address, '3']],
          _sender: address,
        });
    });

    it('should return on canceled price callback', async () => {
      const { traceTree } = await locklift.tracing.trace(
        aggregatorExample.methods
          .getPrices({
            _tokens: [address, zeroAddress],
            _proxy: false,
            _callbackRecipient: callbacksExample.address,
            _payload: '',
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('getPrices')
        .count(1)
        .withNamedArgs({
          _tokens: [address, zeroAddress],
          _proxy: false,
          _callbackRecipient: callbacksExample.address,
          _payload: EmptyTvmCell,
          _remainingGasTo: address,
        })
        .and.to.call('onCanceledPriceCallback')
        .count(1)
        .withNamedArgs({
          _prices: [[address, '1']],
          _scales: [[address, '3']],
          _failed: [zeroAddress],
          _sender: address,
        });
    });
  });
});
