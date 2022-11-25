import { Address, WalletTypes, Contract, lockliftChai } from 'locklift';
import chai, { expect } from 'chai';
import { FactorySource } from '../build/factorySource';

chai.use(lockliftChai);

describe('Version', () => {
  let address: Address;
  let example: Contract<FactorySource['VersionExample']>;

  before('deploy contracts', async () => {
    const signer = await locklift.keystore.getSigner('0');

    const { account } = await locklift.factory.accounts.addNewAccount({
      value: locklift.utils.toNano(100),
      publicKey: signer.publicKey,
      type: WalletTypes.WalletV3,
    });

    address = account.address;

    const { contract } = await locklift.factory.deployContract({
      contract: 'VersionExample',
      publicKey: signer.publicKey,
      initParams: { _nonce: locklift.utils.getRandomNonce() },
      constructorParams: { _remainingGasTo: address },
      value: locklift.utils.toNano(10),
    });

    example = contract;
  });

  describe('check balance and versions after deploy', () => {
    it('should return balance 1 ever', async () => {
      const balance = await locklift.provider.getBalance(example.address);

      return expect(balance).to.be.equal(locklift.utils.toNano(1));
    });

    it('should return initial VersionChanged event', async () => {
      const events = await example.getPastEvents({
        filter: (event) => event.event === 'VersionChanged',
      });

      expect(events.events.length).to.be.equal(1);
      expect(events.events[0].data.current).to.be.equal('1');
      return expect(events.events[0].data.previous).to.be.equal('0');
    });

    it('should return current version 1', async () => {
      const version = await example.methods.getVersion({ answerId: 0 }).call();

      return expect(version.value0).to.be.equal('1');
    });
  });
});
