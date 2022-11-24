import { Address, WalletTypes, Contract, lockliftChai } from 'locklift';
import chai, { expect } from 'chai';
import { FactorySource } from '../build/factorySource';
import { Errors } from './errors';
import { EmptyTvmCell } from './contants';

chai.use(lockliftChai);

describe('FactoryWithPlatform', () => {
  let address: Address;
  let example: Contract<FactorySource['FactoryWithPlatformExample']>;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract } = await locklift.factory.deployContract({
      contract: 'FactoryWithPlatformExample',
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
    it('should return balance 1 ever', async () => {
      const balance = await locklift.provider.getBalance(example.address);

      return expect(balance).to.be.equal(locklift.utils.toNano(1));
    });

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

      return expect(code.value0).to.be.equal(EmptyTvmCell);
    });

    it('should return empty platform code', async () => {
      const code = await example.methods
        .getPlatformCode({ answerId: 0 })
        .call();

      return expect(code.value0).to.be.equal(EmptyTvmCell);
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

    it('should return empty PlatformCodeSet event', async () => {
      const events = await example.getPastEvents({
        filter: (event) => event.event === 'PlatformCodeSet',
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
            _newInstanceVersion: null,
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      // expect(traceTree.getBalanceDiff(example)).to.be.equal('0');
      return expect(traceTree)
        .to.call('setInstanceCode')
        .count(1)
        .withNamedArgs({
          _newInstanceCode: FactoryInstance.code,
          _remainingGasTo: address,
        })
        .and.emit('InstanceVersionChanged')
        .count(1)
        .withNamedArgs({ current: '1', previous: '0' });
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

  describe('update platform code and check event', () => {
    it('should update platform code', async () => {
      const FactoryPlatform =
        locklift.factory.getContractArtifacts('FactoryPlatform');

      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .setPlatformCode({
            _newPlatformCode: FactoryPlatform.code,
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      // expect(traceTree.getBalanceDiff(example)).to.be.equal('0');
      return expect(traceTree)
        .to.call('setPlatformCode')
        .count(1)
        .withNamedArgs({
          _newPlatformCode: FactoryPlatform.code,
          _remainingGasTo: address,
        })
        .and.emit('PlatformCodeSet')
        .count(1);
    });

    it('should return platform code', async () => {
      const FactoryPlatform =
        locklift.factory.getContractArtifacts('FactoryPlatform');

      const code = await example.methods
        .getPlatformCode({ answerId: 0 })
        .call();

      return expect(code.value0).to.be.equal(FactoryPlatform.code);
    });

    it('should throw PLATFORM_CODE_ALREADY_SET for second update', async () => {
      const FactoryPlatform =
        locklift.factory.getContractArtifacts('FactoryPlatform');

      const { traceTree } = await locklift.tracing.trace(
        example.methods
          .setPlatformCode({
            _newPlatformCode: FactoryPlatform.code,
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
        { allowedCodes: { compute: [Errors.PLATFORM_CODE_ALREADY_SET] } },
      );

      return expect(traceTree)
        .to.call('setPlatformCode')
        .count(1)
        .withNamedArgs({
          _newPlatformCode: FactoryPlatform.code,
          _remainingGasTo: address,
        })
        .and.have.error(Errors.PLATFORM_CODE_ALREADY_SET);
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

      // expect(traceTree.getBalanceDiff(example)).to.be.equal('0');
      return expect(traceTree).to.call('deploy').count(1).withNamedArgs({
        _deployParams: params.value0,
        _remainingGasTo: address,
      });
    });

    it('should check instance address', async () => {
      const params = await example.methods
        .getDeployParams({ _id: 0, answerId: 0 })
        .call();

      const instanceAddress = await example.methods
        .getInstanceAddress({ _deployParams: params.value0, answerId: 0 })
        .call();

      const instance = locklift.factory.getDeployedContract(
        'FactoryInstance',
        instanceAddress.value0,
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
        deployParams: string;
        version: string;
        deployer: Address;
      };

      expect(events.events.length).to.be.equal(1);
      expect(data.instance.toString()).to.be.equal(contract.value0.toString());
      expect(data.deployParams).to.be.equal(params.value0);
      expect(data.version).to.be.equal('1');
      return expect(data.deployer.toString()).to.be.equal(address.toString());
    });
  });
});
