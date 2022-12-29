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
import { EmptyTvmCell } from './contants';
import { BigNumber } from 'bignumber.js';

BigNumber.config({ EXPONENTIAL_AT: 1e9 });

chai.use(lockliftChai);

describe('UpgradableByRequest', () => {
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

    const { contract } = await locklift.factory.deployContract({
      contract: 'UpgraderExample',
      publicKey: signer0.publicKey,
      initParams: { _nonce: locklift.utils.getRandomNonce() },
      constructorParams: {
        _initialOwner: address,
        _remainingGasTo: address,
      },
      value: locklift.utils.toNano(10),
    });

    upgraderExample = contract;
  });

  describe('check upgrader after deploy', () => {
    it('should return balance 1 ever', async () => {
      const balance = await locklift.provider.getBalance(
        upgraderExample.address,
      );

      return expect(balance).to.be.equal(locklift.utils.toNano(1));
    });
  });

  describe('deploy upgradable by request instance', () => {
    it('should set instance code', async () => {
      const UpgradableByRequestExample = locklift.factory.getContractArtifacts(
        'UpgradableByRequestExample',
      );

      const { traceTree } = await locklift.tracing.trace(
        upgraderExample.methods
          .setInstanceCode({
            _newInstanceCode: UpgradableByRequestExample.code,
            _newInstanceVersion: null,
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      // expect(traceTree.getBalanceDiff(upgraderExample)).to.be.equal('0');
      return expect(traceTree)
        .to.call('setInstanceCode')
        .count(1)
        .withNamedArgs({
          _newInstanceCode: UpgradableByRequestExample.code,
          _remainingGasTo: address,
        })
        .and.to.emit('InstanceVersionChanged')
        .count(1)
        .withNamedArgs({
          current: '1',
          previous: '0',
          currentCodeHash: new BigNumber(
            UpgradableByRequestExample.codeHash,
            16,
          ).toString(),
          previousCodeHash:
            '68134197439415885698044414435951397869210496020759160419881882418413283430343',
        });
    });

    it('should deploy new instance', async () => {
      const params = await upgraderExample.methods
        .getDeployParams({ _id: 1, answerId: 0 })
        .call();

      const { traceTree } = await locklift.tracing.trace(
        upgraderExample.methods
          .deploy({ _deployParams: params.value0, _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      const upgradableExampleAddress = await upgraderExample.methods
        .getInstanceAddress({ _deployParams: params.value0, answerId: 0 })
        .call();

      upgradableExample = locklift.factory.getDeployedContract(
        'UpgradableByRequestExample',
        upgradableExampleAddress.value0,
      );

      // expect(traceTree.getBalanceDiff(upgraderExample)).to.be.equal('0');
      return expect(traceTree)
        .to.call('deploy')
        .count(1)
        .withNamedArgs({
          _deployParams: params.value0,
          _remainingGasTo: address,
        })
        .and.to.emit('UpgraderChanged')
        .count(1)
        .withNamedArgs({
          current: upgraderExample.address,
          previous: zeroAddress,
        });
    });
  });

  describe('check instance after deploy', () => {
    it('should return balance 1 ever', async () => {
      const balance = await locklift.provider.getBalance(
        upgradableExample.address,
      );

      return expect(balance).to.be.equal(locklift.utils.toNano(1));
    });

    it('should return instance version 1', async () => {
      const version = await upgradableExample.methods
        .getVersion({ answerId: 0 })
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

  describe('update instance code and check version and event', () => {
    it('should update instance code', async () => {
      const UpgradableByRequestExample = locklift.factory.getContractArtifacts(
        'UpgradableByRequestExample',
      );

      const { traceTree } = await locklift.tracing.trace(
        upgraderExample.methods
          .setInstanceCode({
            _newInstanceCode: UpgradableByRequestExample.code,
            _newInstanceVersion: null,
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      // expect(traceTree.getBalanceDiff(upgraderExample)).to.be.equal('0');
      return expect(traceTree)
        .to.call('setInstanceCode')
        .count(1)
        .withNamedArgs({
          _newInstanceCode: UpgradableByRequestExample.code,
          _remainingGasTo: address,
        })
        .to.emit('InstanceVersionChanged')
        .count(1)
        .withNamedArgs({
          previous: '1',
          current: '2',
          currentCodeHash: new BigNumber(
            UpgradableByRequestExample.codeHash,
            16,
          ).toString(),
          previousCodeHash: new BigNumber(
            UpgradableByRequestExample.codeHash,
            16,
          ).toString(),
        });
    });

    it('should return code version 2', async () => {
      const version = await upgraderExample.methods
        .getInstanceVersion({ answerId: 0 })
        .call();

      return expect(version.value0).to.be.equal('2');
    });
  });

  describe('request instance upgrade and check version and event', () => {
    it('should throw CALLER_IS_NOT_UPGRADER for account', async () => {
      const { traceTree } = await locklift.tracing.trace(
        upgradableExample.methods
          .upgrade({ _version: 2, _code: '', _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
        { allowedCodes: { compute: [Errors.CALLER_IS_NOT_UPGRADER] } },
      );

      return expect(traceTree)
        .to.call('upgrade')
        .count(1)
        .withNamedArgs({
          _version: '2',
          _code: EmptyTvmCell,
          _remainingGasTo: address,
        })
        .and.have.error(Errors.CALLER_IS_NOT_UPGRADER);
    });

    it('should throw CALLER_IS_NOT_INSTANCE', async () => {
      const params = await upgraderExample.methods
        .getDeployParams({ _id: 1, answerId: 0 })
        .call();

      const { traceTree } = await locklift.tracing.trace(
        upgraderExample.methods
          .provideUpgrade({
            _instanceVersion: '0',
            _deployParams: params.value0,
            _remainingGasTo: address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
        { allowedCodes: { compute: [Errors.CALLER_IS_NOT_INSTANCE] } },
      );

      return expect(traceTree)
        .to.call('provideUpgrade')
        .count(1)
        .withNamedArgs({
          _instanceVersion: '0',
          _deployParams: params.value0,
          _remainingGasTo: address,
        })
        .and.have.error(Errors.CALLER_IS_NOT_INSTANCE);
    });

    it('should upgrade instance', async () => {
      const { traceTree } = await locklift.tracing.trace(
        upgradableExample.methods
          .requestUpgrade({ _remainingGasTo: address })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      // expect(traceTree.getBalanceDiff(upgradableExample)).to.be.equal('0');
      return expect(traceTree)
        .to.call('requestUpgrade')
        .count(1)
        .withNamedArgs({ _remainingGasTo: address })
        .and.to.call('provideUpgrade')
        .count(1)
        .withNamedArgs({
          _instanceVersion: '1',
          _remainingGasTo: address,
        })
        .and.to.call('upgrade')
        .count(1)
        .withNamedArgs({
          _version: '2',
          _remainingGasTo: address,
        })
        .and.to.emit('VersionChanged')
        .count(1)
        .withNamedArgs({ current: '2', previous: '1' });
    });

    it('should return instance version 2', async () => {
      const version = await upgradableExample.methods
        .getVersion({ answerId: 0 })
        .call();

      return expect(version.value0).to.be.equal('2');
    });
  });
});
