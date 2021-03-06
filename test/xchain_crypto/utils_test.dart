import 'package:test/test.dart';
import 'package:xchain_dart/src/xchain_crypto/utils.dart';

void main() {
  test('is empty', () {
    String source = '';
    List<AssetAddress> addresses = [];
    try {
      addresses = substractAddress(source);
    } catch (err) {
      expect((err as ArgumentError).message, 'Input is empty');
    } finally {
      expect(addresses, isEmpty);
    }
  });

  test('contains spaces', () {
    String source =
        '3QaesQ25kJc4tyCQM5wJ54ky39DNsUMx7Z 0xC52A857FDa38994CB6CC8e0DE2AEDD67a7353e0d';
    try {
      substractAddress(source);
    } catch (err) {
      expect((err as ArgumentError).message, 'Illegal character');
    }
  });

  test('starts with bitcoin chain prefix', () {
    String source = 'bitcoin:3QaesQ25kJc4tyCQM5wJ54ky39DNsUMx7Z';
    List<AssetAddress> addresses = substractAddress(source);
    expect(addresses.length, 1);
    expect(addresses.first.address, '3QaesQ25kJc4tyCQM5wJ54ky39DNsUMx7Z');
    expect(addresses.first.asset, 'BTC.BTC');
    expect(addresses.first.networkType, 'mainnet');
  });

  test('starts with bitcoin chain prefix', () {
    String source = 'BITCOIN:BC1QFPFPW7DLQT3AZCYQXMCUZM5L2XRM6PD6ZVSE9Q';
    List<AssetAddress> addresses = substractAddress(source);
    expect(addresses.length, 1);
    expect(
        addresses.first.address, 'BC1QFPFPW7DLQT3AZCYQXMCUZM5L2XRM6PD6ZVSE9Q');
    expect(addresses.first.asset, 'BTC.BTC');
    expect(addresses.first.networkType, 'mainnet');
  });

  test('starts with bitcoin cash chain prefix', () {
    String source = 'bitcoincash:qpl4lfjq7emfg8p4akr6p27dap5duj35zcc82aqul5';
    List<AssetAddress> addresses = substractAddress(source);
    expect(addresses.length, 1);
    expect(
        addresses.first.address, 'qpl4lfjq7emfg8p4akr6p27dap5duj35zcc82aqul5');
    expect(addresses.first.asset, 'BCH.BCH');
    expect(addresses.first.networkType, 'mainnet');
  });

  test('starts with ethereum chain prefix', () {
    String source = 'ethereum:0xC52A857FDa38994CB6CC8e0DE2AEDD67a7353e0d';
    List<AssetAddress> addresses = substractAddress(source);
    expect(
        addresses.first.address, '0xC52A857FDa38994CB6CC8e0DE2AEDD67a7353e0d');
    expect(addresses.first.asset, 'ETH.ETH');
    expect(addresses.first.networkType, 'mainnet');
  });

  test('starts with unsupported chain prefix', () {
    String source = 'unsupported:0xC52A857FDa38994CB6CC8e0DE2AEDD67a7353e0d';
    List<AssetAddress> addresses = [];
    try {
      addresses = substractAddress(source);
    } catch (err) {
      expect((err as ArgumentError).message, 'Unsupported chain prefix');
    } finally {
      expect(addresses.length, 0);
    }
  });

  test('starts with binance chain prefix', () {
    String source = 'binance:bnb1vxyxxkqdke8r55r6fzhprtj8qwgecudj0h5svr';
    List<AssetAddress> addresses = substractAddress(source);
    expect(
        addresses.first.address, 'bnb1vxyxxkqdke8r55r6fzhprtj8qwgecudj0h5svr');
    expect(addresses.first.asset, 'BNB.BNB');
    expect(addresses.first.networkType, 'mainnet');
  });

  test('bitcoin legacy address without chain prefix', () {
    String source = '16we9adsewmBDKv5CSgeRMZPo3RadcgVZV';
    List<AssetAddress> addresses = substractAddress(source);
    expect(addresses.length, 2);
    expect(addresses.first.address, '16we9adsewmBDKv5CSgeRMZPo3RadcgVZV');
    expect(addresses[0].asset, 'BCH.BCH');
    expect(addresses[1].asset, 'BTC.BTC');
    expect(addresses.first.networkType, 'mainnet');
  });

  test('bitcoin segwit address without chain prefix', () {
    String source = '3QaesQ25kJc4tyCQM5wJ54ky39DNsUMx7Z';
    List<AssetAddress> addresses = substractAddress(source);
    expect(addresses.length, 2);
    expect(addresses.first.address, '3QaesQ25kJc4tyCQM5wJ54ky39DNsUMx7Z');
    expect(addresses[0].asset, 'BTC.BTC');
    expect(addresses[1].asset, 'LTC.LTC');
    expect(addresses.first.networkType, 'mainnet');
  });

  test('bitcoin native segwit address without chain prefix', () {
    String source = 'bc1qfw00pnu77vvw3r8fpterjukx0u3nj26n724pq3';
    List<AssetAddress> addresses = substractAddress(source);
    expect(addresses.length, 1);
    expect(
        addresses.first.address, 'bc1qfw00pnu77vvw3r8fpterjukx0u3nj26n724pq3');
    expect(addresses.first.asset, 'BTC.BTC');
    expect(addresses.first.networkType, 'mainnet');
  });

  test('bitcoin native segwit testnet address without chain prefix', () {
    String source = 'tb1qfcx8ek6y869l3y2nqfvtrdtz9zjls56cnhuyv4';
    List<AssetAddress> addresses = substractAddress(source);
    expect(addresses.length, 1);
    expect(
        addresses.first.address, 'tb1qfcx8ek6y869l3y2nqfvtrdtz9zjls56cnhuyv4');
    expect(addresses.first.asset, 'BTC.tBTC');
    expect(addresses.first.networkType, 'testnet');
  });

  test('ethereum address without chain prefix', () {
    String source = '0xC52A857FDa38994CB6CC8e0DE2AEDD67a7353e0d';
    List<AssetAddress> addresses = substractAddress(source);
    expect(
        addresses.first.address, '0xC52A857FDa38994CB6CC8e0DE2AEDD67a7353e0d');
    expect(addresses.first.asset, 'ETH.ETH');
    expect(addresses.first.networkType, 'mainnet');
  });

  test('unsupported Chain address', () {
    String source = 'AJXPYa2aYizxXfhcEcmom1xuEyZLF6DX5b';
    List<AssetAddress> addresses = [];
    try {
      addresses = substractAddress(source);
    } catch (err) {
      expect((err as ArgumentError).message, 'Unsupported chain');
    } finally {
      expect(addresses, isEmpty);
    }
  });
}
