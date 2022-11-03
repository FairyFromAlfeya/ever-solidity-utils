import {
  Address,
  WalletTypes,
  Contract,
  zeroAddress,
  lockliftChai,
} from 'locklift';
import chai, { expect } from 'chai';
import { FactorySource } from '../build/factorySource';
import { Errors } from './errors';
import { EmptyTvmCell } from './contants';

chai.use(lockliftChai);

describe('Validatable', () => {
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

  describe('check balance after deploy', () => {
    it('should return balance 1 ever', async () => {
      const balance = await locklift.provider.getBalance(example.address);

      return expect(balance).to.be.equal(locklift.utils.toNano(1));
    });
  });

  describe('validate address', () => {
    it('should be a valid address', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .isValidAddress({ _a: address, _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      // expect(traceTree.getBalanceDiff(example)).to.be.equal('0');
      return expect(traceTree)
        .to.call('isValidAddress')
        .count(1)
        .withNamedArgs({ _a: address, _remainingGasTo: address });
    });

    it('should throw INVALID_ADDRESS for self address', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .isValidAddress({ _a: example.address, _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
        { allowedCodes: { compute: [Errors.INVALID_ADDRESS] } },
      );

      return expect(traceTree)
        .to.call('isValidAddress')
        .count(1)
        .withNamedArgs({ _a: example.address, _remainingGasTo: address })
        .and.have.error(Errors.INVALID_ADDRESS);
    });

    it('should throw INVALID_ADDRESS for nil address', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .isValidAddress({ _a: zeroAddress, _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
        { allowedCodes: { compute: [Errors.INVALID_ADDRESS] } },
      );

      return expect(traceTree)
        .to.call('isValidAddress')
        .count(1)
        .withNamedArgs({ _a: zeroAddress, _remainingGasTo: address })
        .and.have.error(Errors.INVALID_ADDRESS);
    });
  });

  describe('validate TvmCell', () => {
    it('should be valid a TvmCell', async () => {
      const cell = await example.methods
        .getValidTvmCell({ _id: 0, answerId: 0 })
        .call();

      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .isValidTvmCell({ _a: cell.value0, _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      // expect(traceTree.getBalanceDiff(example)).to.be.equal('0');
      return expect(traceTree)
        .to.call('isValidTvmCell')
        .count(1)
        .withNamedArgs({ _a: cell.value0, _remainingGasTo: address });
    });

    it('should throw INVALID_CODE for empty TvmCell', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .isValidTvmCell({ _a: '', _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
        { allowedCodes: { compute: [Errors.INVALID_CODE] } },
      );

      return expect(traceTree)
        .to.call('isValidTvmCell')
        .count(1)
        .withNamedArgs({ _a: EmptyTvmCell, _remainingGasTo: address })
        .and.have.error(Errors.INVALID_CODE);
    });
  });
});
