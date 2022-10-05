import { Address, WalletTypes, Contract, zeroAddress } from 'locklift';
import { expect } from 'chai';
import { FactorySource } from '../build/factorySource';

describe('UpgradableByRequest', async () => {
  let address: Address;
  let upgradableExample: Contract<FactorySource['UpgradableByRequestExample']>;
  let upgraderExample: Contract<FactorySource['UpgraderExample']>;

  before('deploy contracts', async () => {
    const signer0 = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer0.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract: contract1 } = await locklift.factory.deployContract({
      contract: 'UpgraderExample',
      publicKey: signer0.publicKey,
      initParams: { _nonce: locklift.utils.getRandomNonce() },
      constructorParams: {
        _initialOwner: address,
        _remainingGasTo: address,
      },
      value: locklift.utils.toNano(10),
    });

    upgraderExample = contract1;

    const UpgradableByRequestExample = locklift.factory.getContractArtifacts(
      'UpgradableByRequestExample',
    );

    await locklift.tracing.trace(
      upgraderExample.methods
        .setInstanceCode({
          _newCode: UpgradableByRequestExample.code,
          _remainingGasTo: null,
        })
        .send({ amount: locklift.utils.toNano(10), from: address }),
    );

    const params = await upgraderExample.methods
      .getDeployParams({ _id: 1, answerId: 0 })
      .call();

    await locklift.tracing.trace(
      upgraderExample.methods
        .deploy({ _params: params.value0, _remainingGasTo: null })
        .send({ amount: locklift.utils.toNano(10), from: address }),
    );

    const upgradableExampleAddress = await upgraderExample.methods
      .getInstanceAddress({ _params: params.value0, answerId: 0 })
      .call();

    upgradableExample = locklift.factory.getDeployedContract(
      'UpgradableByRequestExample',
      upgradableExampleAddress.value0,
    );
  });

  describe('check event and upgrader after deploy', async () => {
    it('should return initial UpgraderChanged event', async () => {
      const events = await upgradableExample.getPastEvents({
        filter: (event) => event.event === 'UpgraderChanged',
      });

      expect(events.events.length).to.be.equal(1);
      expect(events.events[0].data.previous.toString()).to.be.equal(
        zeroAddress.toString(),
      );
      return expect(events.events[0].data.current.toString()).to.be.equal(
        upgraderExample.address.toString(),
      );
    });

    it('should return instance version 1', async () => {
      const version = await upgradableExample.methods
        .getVersion({ answerId: 0 })
        .call();

      return expect(version.value0).to.be.equal('1');
    });

    it('should return owner', async () => {
      const owner = await upgraderExample.methods
        .getOwner({ answerId: 0 })
        .call();

      return expect(owner.value0.toString()).to.be.equal(address.toString());
    });

    it('should return code version 1', async () => {
      const version = await upgraderExample.methods
        .getInstanceVersion({ answerId: 0 })
        .call();

      return expect(version.value0).to.be.equal('1');
    });

    it('should return upgrader', async () => {
      const upgrader = await upgradableExample.methods
        .getUpgrader({ answerId: 0 })
        .call();

      return expect(upgrader.value0.toString()).to.be.equal(
        upgraderExample.address.toString(),
      );
    });
  });

  describe('update instance code and check version and event', async () => {
    it('should update instance code', async () => {
      const UpgradableByRequestExample = locklift.factory.getContractArtifacts(
        'UpgradableByRequestExample',
      );

      await locklift.tracing.trace(
        upgraderExample.methods
          .setInstanceCode({
            _newCode: UpgradableByRequestExample.code,
            _remainingGasTo: null,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );
    });

    it('should return code version 2', async () => {
      const version = await upgraderExample.methods
        .getInstanceVersion({ answerId: 0 })
        .call();

      return expect(version.value0).to.be.equal('2');
    });

    it('should return InstanceVersionChanged event after update', async () => {
      const events = await upgraderExample.getPastEvents({
        filter: (event) => event.event === 'InstanceVersionChanged',
      });

      const data = events.events[0].data as {
        current: string;
        previous: string;
      };

      expect(events.events.length).to.be.equal(2);
      expect(data.previous).to.be.equal('1');
      return expect(data.current).to.be.equal('2');
    });
  });

  describe('request instance upgrade and check version and event', async () => {
    it('should upgrade instance', async () => {
      await locklift.tracing.trace(
        upgradableExample.methods
          .requestUpgrade({ _remainingGasTo: null })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );
    });

    it('should return instance version 2', async () => {
      const version = await upgradableExample.methods
        .getVersion({ answerId: 0 })
        .call();

      return expect(version.value0).to.be.equal('2');
    });

    it('should return VersionChanged event after update', async () => {
      const events = await upgradableExample.getPastEvents({
        filter: (event) => event.event === 'VersionChanged',
      });

      const data = events.events[0].data as {
        current: string;
        previous: string;
      };

      expect(events.events.length).to.be.equal(2);
      expect(data.previous).to.be.equal('1');
      return expect(data.current).to.be.equal('2');
    });
  });
});
