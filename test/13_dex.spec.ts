import { Address, Contract, WalletTypes, lockliftChai } from 'locklift';
import { FactorySource } from '../build/factorySource';
import chai, { expect } from 'chai';
import {
  DaiTokenRoot,
  DaiWeverPair,
  DexRoot,
  WeverTokenRoot,
} from './contants';

chai.use(lockliftChai);

describe('DEX', () => {
  let address: Address;
  let example: Contract<FactorySource['DexPlatformExample']>;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract } = await locklift.factory.deployContract({
      contract: 'DexPlatformExample',
      publicKey: signer.publicKey,
      initParams: { _nonce: locklift.utils.getRandomNonce() },
      constructorParams: { _remainingGasTo: address },
      value: locklift.utils.toNano(10),
    });

    example = contract;
  });

  describe('check pair address deriving', () => {
    it('should return WEVER-DAI pair address', async () => {
      const DexPlatform = locklift.factory.getContractArtifacts('DexPlatform');

      const pair = await example.methods
        .getPairAddress({
          _platformCode: DexPlatform.code,
          _root: DexRoot,
          _left: WeverTokenRoot,
          _right: DaiTokenRoot,
          answerId: 0,
        })
        .call();

      return expect(pair.value0.toString()).to.be.equal(
        DaiWeverPair.toString(),
      );
    });
  });
});
