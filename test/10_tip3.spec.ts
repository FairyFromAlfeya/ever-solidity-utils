import {
  Address,
  WalletTypes,
  Contract,
  lockliftChai,
  zeroAddress,
} from 'locklift';
import chai, { expect } from 'chai';
import { FactorySource } from '../build/factorySource';
import { EmptyTvmCell, TokenFoo } from './contants';

chai.use(lockliftChai);

describe('TIP3', () => {
  let address: Address;

  let root: Contract<FactorySource['TokenRootUpgradeable']>;
  let rootExample: Contract<FactorySource['TokenRootExample']>;

  let wallet: Contract<FactorySource['TokenWalletUpgradeable']>;
  let walletExample: Contract<FactorySource['TokenWalletExample']>;

  let callbackExample: Contract<
    FactorySource['AcceptTokensTransferCallbackExample']
  >;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const Wallet = locklift.factory.getContractArtifacts(
      'TokenWalletUpgradeable',
    );
    const Platform = locklift.factory.getContractArtifacts(
      'TokenWalletPlatform',
    );

    const { contract } = await locklift.factory.deployContract({
      contract: 'TokenRootUpgradeable',
      publicKey: signer.publicKey,
      initParams: {
        randomNonce_: locklift.utils.getRandomNonce(),
        deployer_: zeroAddress,
        name_: TokenFoo.name,
        symbol_: TokenFoo.symbol,
        decimals_: TokenFoo.decimals,
        walletCode_: Wallet.code,
        rootOwner_: account.address,
        platformCode_: Platform.code,
      },
      constructorParams: {
        initialSupplyTo: address,
        initialSupply: '500',
        deployWalletValue: locklift.utils.toNano(2),
        mintDisabled: false,
        burnByRootDisabled: true,
        burnPaused: true,
        remainingGasTo: account.address,
      },
      value: locklift.utils.toNano(10),
    });

    const walletAddress = await contract.methods
      .walletOf({ walletOwner: address, answerId: 0 })
      .call();

    wallet = locklift.factory.getDeployedContract(
      'TokenWalletUpgradeable',
      walletAddress.value0,
    );

    const { contract: exampleRoot } = await locklift.factory.deployContract({
      contract: 'TokenRootExample',
      publicKey: signer.publicKey,
      initParams: {
        _nonce: locklift.utils.getRandomNonce(),
        _root: contract.address,
      },
      constructorParams: { _remainingGasTo: account.address },
      value: locklift.utils.toNano(10),
    });

    const { contract: exampleWallet } = await locklift.factory.deployContract({
      contract: 'TokenWalletExample',
      publicKey: signer.publicKey,
      initParams: {
        _nonce: locklift.utils.getRandomNonce(),
        _wallet: walletAddress.value0,
      },
      constructorParams: { _remainingGasTo: account.address },
      value: locklift.utils.toNano(10),
    });

    const { contract: exampleCallback } = await locklift.factory.deployContract(
      {
        contract: 'AcceptTokensTransferCallbackExample',
        publicKey: signer.publicKey,
        initParams: { _nonce: locklift.utils.getRandomNonce() },
        constructorParams: {
          _root: contract.address,
          _remainingGasTo: account.address,
        },
        value: locklift.utils.toNano(10),
      },
    );

    root = contract;
    walletExample = exampleWallet;
    rootExample = exampleRoot;
    callbackExample = exampleCallback;
  });

  describe('transfer', () => {
    it('should transfer 100 FOO', async () => {
      const { traceTree } = await locklift.tracing.trace(
        wallet.methods
          .transfer({
            amount: '100',
            deployWalletValue: locklift.utils.toNano(2),
            remainingGasTo: address,
            notify: false,
            recipient: walletExample.address,
            payload: '',
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree)
        .to.call('transfer')
        .count(1)
        .withNamedArgs({
          amount: '100',
          deployWalletValue: locklift.utils.toNano(2),
          remainingGasTo: address,
          notify: false,
          recipient: walletExample.address,
          payload: EmptyTvmCell,
        });
    });
  });

  describe('check TokenRoot', () => {
    it('should return balance 1 ever', async () => {
      const balance = await locklift.provider.getBalance(rootExample.address);

      return expect(balance).to.be.equal(locklift.utils.toNano(1));
    });

    it('should return token name', async () => {
      const { traceTree } = await locklift.tracing.trace(
        rootExample.methods
          .name()
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      return expect(traceTree)
        .to.call('name')
        .count(2)
        .and.to.call('onName')
        .count(1)
        .withNamedArgs({ _name: TokenFoo.name });
    });

    it('should return token symbol', async () => {
      const { traceTree } = await locklift.tracing.trace(
        rootExample.methods
          .symbol()
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      return expect(traceTree)
        .to.call('symbol')
        .count(2)
        .and.to.call('onSymbol')
        .count(1)
        .withNamedArgs({ _symbol: TokenFoo.symbol });
    });

    it('should return token decimals', async () => {
      const { traceTree } = await locklift.tracing.trace(
        rootExample.methods
          .decimals()
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      return expect(traceTree)
        .to.call('decimals')
        .count(2)
        .and.to.call('onDecimals')
        .count(1)
        .withNamedArgs({ _decimals: TokenFoo.decimals });
    });

    it('should return token supply', async () => {
      const { traceTree } = await locklift.tracing.trace(
        rootExample.methods
          .totalSupply()
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      return expect(traceTree)
        .to.call('totalSupply')
        .count(2)
        .and.to.call('onTotalSupply')
        .count(1)
        .withNamedArgs({ _totalSupply: '500' });
    });

    it('should return token owner', async () => {
      const { traceTree } = await locklift.tracing.trace(
        rootExample.methods
          .rootOwner()
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      return expect(traceTree)
        .to.call('rootOwner')
        .count(2)
        .and.to.call('onRootOwner')
        .count(1)
        .withNamedArgs({ _rootOwner: address });
    });

    it('should return token wallet', async () => {
      const { traceTree } = await locklift.tracing.trace(
        rootExample.methods
          .walletOf({ _owner: address })
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      return expect(traceTree)
        .to.call('walletOf')
        .count(2)
        .withNamedArgs({ _owner: address })
        .and.to.call('onWalletOf')
        .count(1);
    });

    it('should deploy wallet', async () => {
      const { traceTree } = await locklift.tracing.trace(
        rootExample.methods
          .deployWallet({
            _owner: address,
            _deployWalletValue: locklift.utils.toNano(0.5),
          })
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      return expect(traceTree)
        .to.call('deployWallet')
        .count(2)
        .withNamedArgs({
          _owner: address,
          _deployWalletValue: locklift.utils.toNano(0.5),
        });
    });
  });

  describe('check TokenWallet', () => {
    it('should return balance 1 ever', async () => {
      const balance = await locklift.provider.getBalance(walletExample.address);

      return expect(balance).to.be.equal(locklift.utils.toNano(1));
    });

    it('should return wallet root', async () => {
      const { traceTree } = await locklift.tracing.trace(
        walletExample.methods
          .root()
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      return expect(traceTree)
        .to.call('root')
        .count(2)
        .and.to.call('onRoot')
        .count(1)
        .withNamedArgs({ _root: root.address });
    });

    it('should return wallet balance', async () => {
      const { traceTree } = await locklift.tracing.trace(
        walletExample.methods
          .balance()
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      return expect(traceTree)
        .to.call('balance')
        .count(2)
        .and.to.call('onBalance')
        .count(1)
        .withNamedArgs({ _balance: '400' });
    });

    it('should return wallet owner', async () => {
      const { traceTree } = await locklift.tracing.trace(
        walletExample.methods
          .owner()
          .send({ amount: locklift.utils.toNano(1), from: address }),
      );

      return expect(traceTree)
        .to.call('owner')
        .count(2)
        .and.to.call('onOwner')
        .count(1)
        .withNamedArgs({ _owner: address });
    });

    it('should transfer 50 FOO to callback example', async () => {
      const { traceTree } = await locklift.tracing.trace(
        walletExample.methods
          .transfer({
            _amount: '50',
            _deployWalletValue: locklift.utils.toNano(2),
            _remainingGasTo: address,
            _notify: true,
            _payload: '',
            _recipient: callbackExample.address,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree).to.call('transfer').count(2);
    });

    it('should transfer 50 FOO to callback example wallet', async () => {
      const callbackWallet = await root.methods
        .walletOf({ walletOwner: callbackExample.address, answerId: 0 })
        .call();

      const { traceTree } = await locklift.tracing.trace(
        walletExample.methods
          .transferToWallet({
            _amount: '50',
            _remainingGasTo: address,
            _notify: true,
            _payload: '',
            _recipientWallet: callbackWallet.value0,
          })
          .send({ amount: locklift.utils.toNano(10), from: address }),
      );

      return expect(traceTree).to.call('transferToWallet').count(2);
    });
  });
});
