import { Address, WalletTypes, Contract, lockliftChai } from 'locklift';
import chai, { expect } from 'chai';
import { FactorySource } from '../build/factorySource';

chai.use(lockliftChai);

describe('Upgradable', () => {
  let address: Address;
  let example: Contract<FactorySource['UpgradableExample']>;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract } = await locklift.factory.deployContract({
      contract: 'UpgradableExample',
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
    it('should return empty VersionChanged event', async () => {
      const events = await example.getPastEvents({
        filter: (event) => event.event === 'VersionChanged',
      });

      return expect(events.events.length).to.be.equal(0);
    });

    it('should return version 0', async () => {
      const version = await example.methods.getVersion({ answerId: 0 }).call();

      return expect(version.value0).to.be.equal('0');
    });
  });

  describe('upgrade and check data', () => {
    it('should upgrade contract', async () => {
      const Upgradable =
        locklift.factory.getContractArtifacts('UpgradableExample');

      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .upgrade({ _code: Upgradable.code, _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('upgrade')
        .count(1)
        .withNamedArgs({ _code: Upgradable.code, _remainingGasTo: address })
        .and.to.emit('VersionChanged')
        .count(1)
        .withNamedArgs({ current: '1' });
    });

    it('should return version 1', async () => {
      const version = await example.methods.getVersion({ answerId: 0 }).call();

      return expect(version.value0).to.be.equal('1');
    });

    it('should return account as owner', async () => {
      const owner = await example.methods.getOwner({ answerId: 0 }).call();

      return expect(owner.value0.toString()).to.be.equal(address.toString());
    });
  });
});
