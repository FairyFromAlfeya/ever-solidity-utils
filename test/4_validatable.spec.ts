import { Address, WalletTypes, Contract, zeroAddress } from 'locklift';
import { expect } from 'chai';
import { FactorySource } from '../build/factorySource';

describe('Validatable', async () => {
  let address: Address;
  let example: Contract<FactorySource['ValidatableExample']>;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract } = await locklift.factory.deployContract({
      contract: 'ValidatableExample',
      publicKey: signer.publicKey,
      initParams: { _nonce: locklift.utils.getRandomNonce() },
      constructorParams: { _remainingGasTo: address },
      value: locklift.utils.toNano(10),
    });

    example = contract;
  });

  describe('validate address', async () => {
    it('should be a valid address', async () => {
      await locklift.tracing.trace(
        example.methods
          .isValidAddress({ _a: address, _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );
    });

    it('should throw INVALID_ADDRESS for self address', async () => {
      await locklift.tracing.trace(
        example.methods
          .isValidAddress({ _a: example.address, _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: address }),
        { allowedCodes: { compute: [206] } },
      );

      const txs = await locklift.provider
        .getTransactions({ address: example.address })
        .then((txs) => txs.transactions.filter((tx) => tx.exitCode === 206));

      return expect(txs.length).to.be.equal(1);
    });

    it('should throw INVALID_ADDRESS for nil address', async () => {
      await locklift.tracing.trace(
        example.methods
          .isValidAddress({ _a: zeroAddress, _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: address }),
        { allowedCodes: { compute: [206] } },
      );

      const txs = await locklift.provider
        .getTransactions({ address: example.address })
        .then((txs) => txs.transactions.filter((tx) => tx.exitCode === 206));

      return expect(txs.length).to.be.equal(2);
    });
  });

  describe('validate TvmCell', async () => {
    it('should be valid a TvmCell', async () => {
      const cell = await example.methods
        .getValidTvmCell({ _id: 0, answerId: 0 })
        .call();

      await locklift.tracing.trace(
        example.methods
          .isValidTvmCell({ _a: cell.value0, _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );
    });

    it('should throw INVALID_CODE for empty TvmCell', async () => {
      await locklift.tracing.trace(
        example.methods
          .isValidTvmCell({ _a: '', _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: address }),
        { allowedCodes: { compute: [204] } },
      );

      const txs = await locklift.provider
        .getTransactions({ address: example.address })
        .then((txs) => txs.transactions.filter((tx) => tx.exitCode === 204));

      return expect(txs.length).to.be.equal(1);
    });
  });
});
