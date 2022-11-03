import { Address, WalletTypes, Contract, lockliftChai } from 'locklift';
import chai, { expect } from 'chai';
import { FactorySource } from '../build/factorySource';

chai.use(lockliftChai);

describe('Reservable', () => {
  let address: Address;
  let example: Contract<FactorySource['ReservableExample']>;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract } = await locklift.factory.deployContract({
      contract: 'ReservableExample',
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

  describe('refund', () => {
    it('should refund remaining gas manually', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .reserveGas({ _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      expect(traceTree.getBalanceDiff(example)).to.be.equal('0');
      return expect(traceTree)
        .to.call('reserveGas')
        .count(1)
        .withNamedArgs({ _remainingGasTo: address });
    });

    it('should refund remaining gas automatically', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .reserveAndRefundGas({ _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      expect(traceTree.getBalanceDiff(example)).to.be.equal('0');
      return expect(traceTree)
        .to.call('reserveAndRefundGas')
        .count(1)
        .withNamedArgs({ _remainingGasTo: address });
    });
  });
});
