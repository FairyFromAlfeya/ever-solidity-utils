import { Address, WalletTypes, Contract, zeroAddress } from 'locklift';
import { expect } from 'chai';
import { FactorySource } from '../build/factorySource';

describe('Ownable', async () => {
  let firstAccount: Address;
  let secondAccount: Address;
  let example: Contract<FactorySource['OwnableExample']>;

  before('deploy contracts', async () => {
    const signer0 = await locklift.keystore.getSigner('0');
    const signer1 = await locklift.keystore.getSigner('1');

    const { account: account1 } = await locklift.factory.accounts.addNewAccount(
      {
        value: locklift.utils.toNano(100),
        publicKey: signer0.publicKey,
        type: WalletTypes.WalletV3,
      },
    );

    const { account: account2 } = await locklift.factory.accounts.addNewAccount(
      {
        value: locklift.utils.toNano(100),
        publicKey: signer1.publicKey,
        type: WalletTypes.WalletV3,
      },
    );

    firstAccount = account1.address;
    secondAccount = account2.address;

    const { contract } = await locklift.factory.deployContract({
      contract: 'OwnableExample',
      publicKey: signer0.publicKey,
      initParams: { _nonce: locklift.utils.getRandomNonce() },
      constructorParams: {
        _initialOwner: firstAccount,
        _remainingGasTo: firstAccount,
      },
      value: locklift.utils.toNano(10),
    });

    example = contract;
  });

  describe('check event and owner after deploy', async () => {
    it('should return initial OwnerChanged event', async () => {
      const events = await example.getPastEvents({
        filter: (event) => event.event === 'OwnerChanged',
      });

      expect(events.events.length).to.be.equal(1);
      expect(events.events[0].data.previous.toString()).to.be.equal(
        zeroAddress.toString(),
      );
      return expect(events.events[0].data.current.toString()).to.be.equal(
        firstAccount.toString(),
      );
    });

    it('should return first account as owner', async () => {
      const owner = await example.methods.getOwner({ answerId: 0 }).call();

      return expect(owner.value0.toString()).to.be.equal(
        firstAccount.toString(),
      );
    });
  });

  describe('update owner and check event and new owner', async () => {
    it('should throw CALLER_IS_NOT_OWNER for second account', async () => {
      await locklift.tracing.trace(
        example.methods
          .setOwner({ _newOwner: secondAccount, _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: secondAccount }),
        { allowedCodes: { compute: [200] } },
      );

      const txs = await locklift.provider
        .getTransactions({ address: example.address })
        .then((txs) => txs.transactions.filter((tx) => tx.exitCode === 200));

      return expect(txs.length).to.be.equal(1);
    });

    it('should set second account as owner', async () => {
      await locklift.tracing.trace(
        example.methods
          .setOwner({ _newOwner: secondAccount, _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: firstAccount }),
      );

      const owner = await example.methods.getOwner({ answerId: 0 }).call();

      return expect(owner.value0.toString()).to.be.equal(
        secondAccount.toString(),
      );
    });

    it('should return OwnerChanged event after update', async () => {
      const events = await example.getPastEvents({
        filter: (event) => event.event === 'OwnerChanged',
      });

      expect(events.events.length).to.be.equal(2);
      expect(events.events[0].data.previous.toString()).to.be.equal(
        firstAccount.toString(),
      );
      return expect(events.events[0].data.current.toString()).to.be.equal(
        secondAccount.toString(),
      );
    });

    it('should return second account as owner', async () => {
      const owner = await example.methods.getOwner({ answerId: 0 }).call();

      return expect(owner.value0.toString()).to.be.equal(
        secondAccount.toString(),
      );
    });
  });

  describe('check access modifier', async () => {
    it('should emit event about success from second account', async () => {
      await locklift.tracing.trace(
        example.methods
          .check({ _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: secondAccount }),
      );
    });

    it('should throw CALLER_IS_NOT_OWNER from first account', async () => {
      await locklift.tracing.trace(
        example.methods
          .check({ _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: firstAccount }),
        { allowedCodes: { compute: [200] } },
      );

      const txs = await locklift.provider
        .getTransactions({ address: example.address })
        .then((txs) => txs.transactions.filter((tx) => tx.exitCode === 200));

      return expect(txs.length).to.be.equal(2);
    });
  });
});
