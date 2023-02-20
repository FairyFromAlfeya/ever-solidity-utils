import { Address, WalletTypes, Contract, lockliftChai } from 'locklift';
import chai, { expect } from 'chai';
import { FactorySource } from '../build/factorySource';

chai.use(lockliftChai);

describe('UpgradableWithData', () => {
  let address: Address;
  let example: Contract<FactorySource['UpgradableWithDataExample']>;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract } = await locklift.factory.deployContract({
      contract: 'UpgradableWithDataExample',
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

  describe('check event and version after deploy', () => {
    it('should return balance 1 ever', async () => {
      const balance = await locklift.provider.getBalance(example.address);

      return expect(balance).to.be.equal(locklift.utils.toNano(1));
    });

    it('should return initial VersionChanged event', async () => {
      const events = await example.getPastEvents({
        filter: (event) => event.event === 'VersionChanged',
      });

      expect(events.events.length).to.be.equal(1);
      expect(events.events[0].data.previous).to.be.equal('0');
      return expect(events.events[0].data.current).to.be.equal('1');
    });

    it('should return version 1', async () => {
      const version = await example.methods.getVersion({ answerId: 0 }).call();

      return expect(version.value0).to.be.equal('1');
    });
  });

  describe('upgrade and check data', () => {
    it('should upgrade contract', async () => {
      const Upgradable = locklift.factory.getContractArtifacts(
        'UpgradableWithDataExample',
      );

      const extra = await locklift.provider.packIntoCell({
        structure: [{ name: 'extra', type: 'uint32' }] as const,
        data: { extra: '123' },
      });

      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .upgrade({
            _code: Upgradable.code,
            _version: null,
            _data: extra.boc,
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      // expect(traceTree.getBalanceDiff(example)).to.be.equal('0');
      return expect(traceTree)
        .to.call('upgrade')
        .count(1)
        .withNamedArgs({ _code: Upgradable.code, _remainingGasTo: address })
        .and.to.emit('VersionChanged')
        .count(1)
        .withNamedArgs({ current: '2', previous: '1' });
    });

    it('should return current version 2', async () => {
      const version = await example.methods.getVersion({ answerId: 0 }).call();

      return expect(version.value0).to.be.equal('2');
    });

    it('should return account as owner', async () => {
      const owner = await example.methods.getOwner({ answerId: 0 }).call();

      return expect(owner.value0.toString()).to.be.equal(address.toString());
    });

    it('should return extra value 123', async () => {
      const extra = await example.methods.getExtra({ answerId: 0 }).call();

      return expect(extra.value0).to.be.equal('123');
    });
  });
});
