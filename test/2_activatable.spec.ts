import { Address, WalletTypes, Contract, lockliftChai } from 'locklift';
import chai, { expect } from 'chai';
import { FactorySource } from '../build/factorySource';
import { Errors } from './errors';

chai.use(lockliftChai);

describe('Activatable', () => {
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

  describe('check event and active status after deploy', () => {
    it('should return balance 1 ever', async () => {
      const balance = await locklift.provider.getBalance(example.address);

      return expect(balance).to.be.equal(locklift.utils.toNano(1));
    });

    it('should return empty ActiveChanged event', async () => {
      const events = await example.getPastEvents({
        filter: (event) => event.event === 'ActiveStatusChanged',
      });

      return expect(events.events.length).to.be.equal(0);
    });

    it('should return active status false', async () => {
      const active = await example.methods
        .getActiveStatus({ answerId: 0 })
        .call();

      return expect(active.value0).to.be.false;
    });
  });

  describe('check access modifier with active status false', () => {
    it('should throw CONTRACT_IS_NOT_ACTIVE for active status false', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .check({ _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
        { allowedCodes: { compute: [Errors.CONTRACT_IS_NOT_ACTIVE] } },
      );

      return expect(traceTree)
        .to.call('check')
        .count(1)
        .withNamedArgs({ _remainingGasTo: address })
        .and.have.error(Errors.CONTRACT_IS_NOT_ACTIVE);
    });
  });

  describe('update active status and check event and active status true', () => {
    it('should set active status true', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .setActiveStatus({ _newActiveStatus: true, _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('setActiveStatus')
        .count(1)
        .withNamedArgs({ _newActiveStatus: true, _remainingGasTo: address })
        .and.to.emit('ActiveStatusChanged')
        .count(1)
        .withNamedArgs({ current: true, previous: false });
    });

    it('should return active status true', async () => {
      const isActive = await example.methods
        .getActiveStatus({ answerId: 0 })
        .call();

      return expect(isActive.value0).to.be.true;
    });
  });

  describe('check access modifier with active status true', () => {
    it('should emit event about success', async () => {
      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .check({ _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      // expect(traceTree.getBalanceDiff(example)).to.be.equal('0');
      return expect(traceTree)
        .to.call('check')
        .count(1)
        .withNamedArgs({ _remainingGasTo: address });
    });
  });
});
