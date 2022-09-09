import { Address, WalletTypes, Contract } from 'locklift';
import { expect } from 'chai';
import { FactorySource } from '../build/factorySource';

describe('Activatable', async () => {
  let address: Address;
  let example: Contract<FactorySource['ActivatableExample']>;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract } = await locklift.factory.deployContract({
      contract: 'ActivatableExample',
      publicKey: signer.publicKey,
      initParams: { _nonce: locklift.utils.getRandomNonce() },
      constructorParams: {
        _initialOwner: address,
        _remainingGasTo: address,
      },
      value: locklift.utils.toNano(10),
    });

    example = contract;
  });

  describe('check event and active status after deploy', async () => {
    it('should return empty ActiveChanged event', async () => {
      const events = await example.getPastEvents({
        filter: (event) => event.event === 'ActiveChanged',
      });

      return expect(events.events.length).to.be.equal(0);
    });

    it('should return active status false', async () => {
      const active = await example.methods.getActive({ answerId: 0 }).call();

      return expect(active.value0).to.be.equal(false);
    });
  });

  describe('check access modifier', async () => {
    it('should throw CONTRACT_IS_NOT_ACTIVE for active status false', async () => {
      await locklift.tracing.trace(
        example.methods
          .check({ _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: address }),
        { allowedCodes: { compute: [203] } },
      );

      const txs = await locklift.provider
        .getTransactions({ address: example.address })
        .then((txs) => txs.transactions.filter((tx) => tx.exitCode === 203));

      return expect(txs.length).to.be.equal(1);
    });
  });

  describe('update active status and check event and active status true', async () => {
    it('should set active status true', async () => {
      await locklift.tracing.trace(
        example.methods
          .setActive({ _newActive: true, _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      const active = await example.methods.getActive({ answerId: 0 }).call();

      return expect(active.value0).to.be.equal(true);
    });

    it('should return ActiveChanged event after update', async () => {
      const events = await example.getPastEvents({
        filter: (event) => event.event === 'ActiveChanged',
      });

      expect(events.events.length).to.be.equal(1);
      expect(events.events[0].data.previous).to.be.equal(false);
      return expect(events.events[0].data.current).to.be.equal(true);
    });
  });

  describe('check access modifier', async () => {
    it('should emit event about success', async () => {
      await locklift.tracing.trace(
        example.methods
          .check({ _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );
    });
  });
});
