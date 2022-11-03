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

chai.use(lockliftChai);

describe('Ownable', () => {
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

  describe('check event and owner after deploy', () => {
    it('should return balance 1 ever', async () => {
      const balance = await locklift.provider.getBalance(example.address);

      return expect(balance).to.be.equal(locklift.utils.toNano(1));
    });

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

  describe('update owner and check event and new owner', () => {
    it('should throw CALLER_IS_NOT_OWNER for second account', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .setOwner({
            _newOwner: secondAccount,
            _remainingGasTo: secondAccount,
          })
          .send({ amount: locklift.utils.toNano(10), from: secondAccount }),
        { allowedCodes: { compute: [Errors.CALLER_IS_NOT_OWNER] } },
      );

      return expect(traceTree)
        .to.call('setOwner')
        .count(1)
        .withNamedArgs({
          _newOwner: secondAccount,
          _remainingGasTo: secondAccount,
        })
        .and.have.error(Errors.CALLER_IS_NOT_OWNER);
    });

    it('should set second account as owner', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .setOwner({ _newOwner: secondAccount, _remainingGasTo: firstAccount })
          .send({ amount: locklift.utils.toNano(10), from: firstAccount }),
      );

      // expect(traceTree.getBalanceDiff(example)).to.be.equal('0');
      return expect(traceTree)
        .to.call('setOwner')
        .count(1)
        .withNamedArgs({
          _newOwner: secondAccount,
          _remainingGasTo: firstAccount,
        })
        .and.to.emit('OwnerChanged')
        .count(1)
        .withNamedArgs({ previous: firstAccount, current: secondAccount });
    });

    it('should return second account as owner', async () => {
      const owner = await example.methods.getOwner({ answerId: 0 }).call();

      return expect(owner.value0.toString()).to.be.equal(
        secondAccount.toString(),
      );
    });
  });

  describe('check access modifier', () => {
    it('should emit event about success from second account', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .check({ _remainingGasTo: secondAccount })
          .send({ amount: locklift.utils.toNano(10), from: secondAccount }),
      );

      // expect(traceTree.getBalanceDiff(example)).to.be.equal('0');
      return expect(traceTree)
        .to.call('check')
        .count(1)
        .withNamedArgs({ _remainingGasTo: secondAccount });
    });

    it('should throw CALLER_IS_NOT_OWNER from first account', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .check({ _remainingGasTo: firstAccount })
          .send({ amount: locklift.utils.toNano(10), from: firstAccount }),
        { allowedCodes: { compute: [Errors.CALLER_IS_NOT_OWNER] } },
      );

      return expect(traceTree)
        .to.call('check')
        .count(1)
        .withNamedArgs({ _remainingGasTo: firstAccount })
        .and.have.error(Errors.CALLER_IS_NOT_OWNER);
    });
  });
});
