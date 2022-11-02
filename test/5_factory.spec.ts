import { Address, WalletTypes, Contract, lockliftChai } from 'locklift';
import chai, { expect } from 'chai';
import { FactorySource } from '../build/factorySource';

chai.use(lockliftChai);

describe('Factory', () => {
  let address: Address;
  let example: Contract<FactorySource['FactoryExample']>;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract } = await locklift.factory.deployContract({
      contract: 'FactoryExample',
      publicKey: signer.publicKey,
      initParams: { _nonce: locklift.utils.getRandomNonce() },
      constructorParams: {
        _remainingGasTo: address,
        _initialOwner: address,
      },
      value: locklift.utils.toNano(10),
    });

    example = contract;
  });

  describe('check events and code after deploy', () => {
    it('should return instance version 0', async () => {
      const version = await example.methods
        .getInstanceVersion({ answerId: 0 })
        .call();

      return expect(version.value0).to.be.equal('0');
    });

    it('should return empty instance code', async () => {
      const code = await example.methods
        .getInstanceCode({ answerId: 0 })
        .call();

      return expect(code.value0).to.be.equal('te6ccgEBAQEAAgAAAA==');
    });

    it('should return empty InstanceDeployed event', async () => {
      const events = await example.getPastEvents({
        filter: (event) => event.event === 'InstanceDeployed',
      });

      return expect(events.events.length).to.be.equal(0);
    });

    it('should return empty InstanceVersionChanged event', async () => {
      const events = await example.getPastEvents({
        filter: (event) => event.event === 'InstanceVersionChanged',
      });

      return expect(events.events.length).to.be.equal(0);
    });
  });

  describe('update instance code and check version and event', () => {
    it('should update instance code', async () => {
      const FactoryInstance =
        locklift.factory.getContractArtifacts('FactoryInstance');

      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .setInstanceCode({
            _newInstanceCode: FactoryInstance.code,
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('setInstanceCode')
        .count(1)
        .withNamedArgs({
          _newInstanceCode: FactoryInstance.code,
          _remainingGasTo: address,
        })
        .and.emit('InstanceVersionChanged')
        .count(1)
        .withNamedArgs({ current: '1' });
    });

    it('should return instance code', async () => {
      const FactoryInstance =
        locklift.factory.getContractArtifacts('FactoryInstance');

      const code = await example.methods
        .getInstanceCode({ answerId: 0 })
        .call();

      return expect(code.value0).to.be.equal(FactoryInstance.code);
    });

    it('should return instance version 1', async () => {
      const version = await example.methods
        .getInstanceVersion({ answerId: 0 })
        .call();

      return expect(version.value0).to.be.equal('1');
    });
  });

  describe('deploy new instance and check', () => {
    it('should deploy instance with id 0', async () => {
      const params = await example.methods
        .getDeployParams({ _id: 0, answerId: 0 })
        .call();

      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .deploy({ _deployParams: params.value0, _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('deploy')
        .count(1)
        .withNamedArgs({ _deployParams: params.value0, _remainingGasTo: address });
    });

    it('should check instance address', async () => {
      const params = await example.methods
        .getDeployParams({ _id: 0, answerId: 0 })
        .call();

      const contract = await example.methods
        .getInstanceAddress({ _deployParams: params.value0, answerId: 0 })
        .call();

      const instance = locklift.factory.getDeployedContract(
        'FactoryInstance',
        contract.value0,
      );

      const { traceTree } = await locklift.tracing.trace(
        instance.methods
          .check({ _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('check')
        .count(1)
        .withNamedArgs({ _remainingGasTo: address });
    });

    it('should return InstanceDeployed event after deploy', async () => {
      const params = await example.methods
        .getDeployParams({ _id: 0, answerId: 0 })
        .call();

      const contract = await example.methods
        .getInstanceAddress({ _deployParams: params.value0, answerId: 0 })
        .call();

      const events = await example.getPastEvents({
        filter: (event) => event.event === 'InstanceDeployed',
      });

      const data = events.events[0].data as {
        instance: Address;
        version: string;
        deployer: Address;
      };

      expect(events.events.length).to.be.equal(1);
      expect(data.instance.toString()).to.be.equal(contract.value0.toString());
      expect(data.version).to.be.equal('1');
      return expect(data.deployer.toString()).to.be.equal(address.toString());
    });
  });
});
