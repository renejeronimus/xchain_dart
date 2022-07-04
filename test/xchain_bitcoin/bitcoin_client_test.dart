import 'package:bitcoin_dart/bitcoin_flutter.dart';
import 'package:test/test.dart';
import 'package:xchain_dart/xchaindart.dart';

void main() {
  // https://iancoleman.io/bip39/
  const phrase =
      'canyon throw labor waste awful century ugly they found post source draft';

  // m/44'/0'/0'/0/0
  const addrPath0 = '12tSpVdC9CAwod9CFaw33JL9o7JngpE2pJ';
  // m/84'/1'/0'/0/0
  const addrPath1 = 'tb1q669kqq0ykrzgx337w3sj0kdf6zcuznvff34z85';
  // m/84'/0'/0'/0/0
  const addrPath2 = 'bc1qan023kcugy7gslksnffh8ej5rhqajjvu78r3tk';
  // m/84'/0'/0'/0/1
  const addrPath3 = 'bc1qnlnwpt3e3ur0k2cwppypqsr4jfn8pdp3ty0z04';
  // Satoshis address
  const addrPath4 = '1HLoD9E4SDFFPDiYfNYnkBLQ85Y51J3Zb1';

  group('config and setup', () {
    XChainClient client = BitcoinClient(
      phrase,
    );

    test('check if the readOnlyClient flag is set', () {
      expect(client.readOnlyClient, false);
    });
    test('get default network', () {
      var networkType = client.getNetwork();
      expect(networkType, bitcoin);
    });
    test('set testnet network', () {
      client.setNetwork(testnet);
      var networkType = client.getNetwork();
      expect(networkType, testnet);
      expect(client.address, addrPath1);
    });
    test('set phrase', () {
      client.setNetwork(testnet);
      String address = client.setPhrase(phrase, 0);
      expect(address, addrPath1);
    });
  });
  group('bitcoin-client', () {
    XChainClient client = new BitcoinClient(phrase);
    test('check valid address on creation', () {
      expect(client.address, addrPath2);
    });
    test('check valid address on creation', () {
      expect(client.getAddress(1), addrPath3);
    });
  });

  group('empty bitcoin-lite-client', () {
    XChainClient client = new BitcoinClient.readonly(addrPath0);
    test('check if the readOnlyClient flag is set', () {
      expect(client.readOnlyClient, true);
    });
    test('check if address is set on creation', () {
      expect(client.address, addrPath0);
    });
    test('check balance', () async {
      List balances = await client.getBalance(addrPath0, 'BTC.BTC');
      expect(balances.length, 1);
      expect(balances.first['amount'], 0.0);
    });
  });

  group('non-empty bitcoin-lite-client', () {
    XChainClient client = new BitcoinClient.readonly(addrPath4);
    test('check if the readOnlyClient flag is set', () {
      expect(client.readOnlyClient, true);
    });
    test('check if address is set on creation', () {
      expect(client.address, addrPath4);
    });
    test('check balance', () async {
      List balances = await client.getBalance(addrPath4, 'BTC.BTC');
      expect(balances.length, equals(1));
      expect(balances.first['amount'], greaterThan(0.01597));
    });
  });

  group('transaction history', () {
    XChainClient client = new BitcoinClient.readonly(addrPath4);
    test('get specific tx history', () async {
      Map txData = await client.getTransactionData(
          'b12dd481c49c01c3570672e2a5f72efb2deb74a10a5d27a9cbe4483160fe9565');
      expect(
          txData.containsValue(
              '000000000000000000008d1e5a3c919bcd0db96ce149b88da6f6246b0dab3f12'),
          true);
    });
    test('get all tx history', () async {
      List transactions =
          await client.getTransactions('35gHuxDkYMEETK5bXCTDen9rCv5dGz3i7Z', 3);
      Map tx = transactions.first;
      bool asset = tx.containsValue('BTC.BTC');
      expect(asset, true);
      expect(transactions.length, 3);
    });
    test('get all tx history from miner on testnet', () async {
      client.setNetwork(testnet);
      List transactions = await client.getTransactions(
          'tb1qsgx55dp6gn53tsmyjjv4c2ye403hgxynxs0dnm', 1);
      Map tx = transactions.first;
      bool asset = tx.containsValue('BTC.tBTC');
      expect(asset, true);
      expect(transactions.length, 1);
    });
  });

  group('check for address validity', () {
    XChainClient client = new BitcoinClient.readonly(addrPath4);
    test('check default address', () async {
      expect(client.validateAddress(client.address), true);
    });
    test('check native SegWit (P2WPKH) address', () async {
      expect(client.validateAddress(addrPath2), true);
    });
    test('check native SegWit (P2WPKH) testnet address', () async {
      client.setNetwork(testnet);
      expect(client.validateAddress(addrPath1), true);
    });
  });
}
