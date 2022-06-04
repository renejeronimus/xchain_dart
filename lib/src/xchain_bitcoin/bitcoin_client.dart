import 'dart:convert';

import 'package:bip32/bip32.dart' as bip32;
import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_dart/bitcoin_flutter.dart';

import '../../xchaindart.dart';

class BitcoinClient implements XChainClient {
  @override
  late String address;

  @override
  late String network;

  @override
  late bool readOnlyClient;

  @override
  late String seed;

  NetworkHelper _networkHelper = NetworkHelper();

  static const _denominator = 100000000;

  BitcoinClient(this.seed, {this.network = 'mainnet'}) {
    readOnlyClient = false;
    int walletIndex = 0;
    address = getAddress(walletIndex);
  }

  BitcoinClient.readonly(this.address, {this.network = 'mainnet'}) {
    readOnlyClient = true;
    address = this.address;
  }

  @override
  getAddress(walletIndex) {
    if (walletIndex < 0) {
      throw ('index must be greater than zero');
    }

    final seedUint8List = bip39.mnemonicToSeed(seed);
    final root = bip32.BIP32.fromSeed(seedUint8List);

    final address;

    // BIP84 (BIP44 for native segwit)
    if (network == 'testnet') {
      final node = root.derivePath("m/84'/1'/0'/0/$walletIndex");
      address = P2WPKH(
              data: new PaymentData(pubkey: node.publicKey), network: testnet)
          .data
          .address;
    } else {
      final node = root.derivePath("m/84'/0'/0'/0/$walletIndex");
      address =
          P2WPKH(data: new PaymentData(pubkey: node.publicKey)).data.address;
    }

    return address;
  }

  @override
  getBalance(address, assets) async {
    List balances = [];

    String uri = '${getExplorerAddressUrl(address)}';
    String responseBody = await _networkHelper.getData(uri);
    num funded = jsonDecode(responseBody)['chain_stats']['funded_txo_sum'];
    num spend = jsonDecode(responseBody)['chain_stats']['spent_txo_sum'];
    num amount = (funded - spend) / _denominator;
    if (amount != null) {
      balances.add({
        'asset': 'BTC.BTC',
        'amount': amount,
        'image': 'https://s2.coinmarketcap.com/static/img/coins/64x64/1.png'
      });
    }
    return balances;
  }

  @override
  getExplorerAddressUrl(address) {
    return '${this.getExplorerUrl()}/address/${address}';
  }

  @override
  getExplorerTransactionUrl(txId) {
    return '${this.getExplorerUrl()}/tx/${txId}';
  }

  @override
  getExplorerUrl() {
    if (network == 'mainnet') {
      return 'https://blockstream.info/api';
    } else if (network == 'testnet') {
      return 'https://blockstream.info/testnet/api';
    } else {
      throw ArgumentError('Unsupported network');
    }
  }

  @override
  getFees(params) {
    List fees = [
      {
        "type": "byte",
        "fastest": 300,
        "fast": 275,
        "average": 250,
      }
    ];
    return fees;
  }

  @override
  getNetwork() {
    return network;
  }

  @override
  getTransactionData(txId) async {
    var _txData = {};

    String _uri = '${getExplorerTransactionUrl(txId)}';
    String _responseBody = await _networkHelper.getData(_uri);
    var _rawTx = jsonDecode(_responseBody);

    var _confirmed = _rawTx['status']['confirmed'];
    var _hash = _rawTx['status']['block_hash'];
    var _date = DateTime.now();
    if (_confirmed == true) {
      var epoch = _rawTx['status']['block_time'];
      _date =
          new DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: false);
    }

    List<Map> _from = [];
    _rawTx['vin'].forEach((tx) {
      Map _txMap = tx;
      _txMap.forEach((key, value) {
        if (key == 'prevout') {
          Map _prevoutMap = value;
          late String _address;
          late double _amount;
          _prevoutMap.forEach((subkey, subvalue) {
            if (subkey == 'scriptpubkey_address') {
              _address = subvalue;
            }
            if (subkey == 'value') {
              _amount = subvalue / _denominator;
            }
          });
          if (_address.isNotEmpty) {
            var map = {'address': _address, 'amount': _amount};
            _from.add(map);
          }
        }
      });
    });

    List<Map> _to = [];
    _rawTx['vout'].forEach((tx) {
      Map _txMap = tx;
      late String _address;
      late double _amount;
      _txMap.forEach((key, value) {
        if (key == 'scriptpubkey_address') {
          _address = value;
        }

        if (key == 'value') {
          _amount = value / _denominator;
        }
      });
      if (_address.isNotEmpty) {
        var map = {'address': _address, 'amount': _amount};
        _to.add(map);
      }
    });

    if (_rawTx != null) {
      _txData.addAll({
        'asset': 'BTC.BTC',
        'from': _from,
        'to': _to,
        'date': _date,
        'type': "transfer",
        'hash': _hash,
        'confirmed': _confirmed,
      });
    }
    return _txData;
  }

  @override
  getTransactions(address, [limit]) async {
    List _txData = [];
    String _uri = '${getExplorerAddressUrl(address)}/txs';
    String _responseBody = await _networkHelper.getData(_uri);
    List _rawTxs = jsonDecode(_responseBody);

    for (var _rawTx in _rawTxs) {
      var _confirmed = _rawTx['status']['confirmed'];
      var _hash = _rawTx['status']['block_hash'];
      var _date = DateTime.now();
      if (_confirmed == true) {
        var _epoch = _rawTx['status']['block_time'];
        _date = new DateTime.fromMillisecondsSinceEpoch(_epoch * 1000,
            isUtc: false);
      }

      List<Map> _from = [];
      _rawTx['vin'].forEach((tx) {
        Map _txMap = tx;
        _txMap.forEach((key, value) {
          if (key == 'prevout') {
            Map _prevoutMap = value;
            late String _address;
            late double _amount;
            _prevoutMap.forEach((subkey, subvalue) {
              if (subkey == 'scriptpubkey_address') {
                _address = subvalue;
              }
              if (subkey == 'value') {
                _amount = subvalue / _denominator;
              }
            });
            if (_address.isNotEmpty) {
              var _map = {'address': _address, 'amount': _amount};
              _from.add(_map);
            }
          }
        });
      });

      List<Map> _to = [];
      _rawTx['vout'].forEach((tx) {
        Map _txMap = tx;
        late String _address;
        late double _amount;
        _txMap.forEach((key, value) {
          if (key == 'scriptpubkey_address') {
            _address = value;
          }
          if (key == 'value') {
            _amount = value / _denominator;
          }
        });
        if (_address.isNotEmpty) {
          var _map = {'address': _address, 'amount': _amount};
          _to.add(_map);
        }
      });

      _txData.add({
        'asset': 'BTC.BTC',
        'from': _from,
        'to': _to,
        'date': _date,
        'type': "transfer",
        'hash': _hash,
        'confirmed': _confirmed,
      });
    }

    if (limit == null) {
      return _txData;
    } else {
      return _txData.sublist(0, limit);
    }
  }

  @override
  purgeClient() {
    // When a wallet is "locked" the private key should be purged in each client by setting it back to null.
  }

  @override
  setNetwork(newNetwork) {
    network = newNetwork;
    address = getAddress(0);
  }

  @override
  setPhrase(mnemonic, walletIndex) {
    seed = mnemonic;
    address = getAddress(walletIndex);
    return address;
  }

  @override
  transfer(params) {
    String txHash =
        '59bbb95bbe740ad6acf24509d38f13f83ca49d6f11207f6a162999ffc5863b77';
    return txHash;
  }

  @override
  validateAddress(address) {
    // check validity of address
    bool result = true;
    return result;
  }
}
