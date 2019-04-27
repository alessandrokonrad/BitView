import "package:pointycastle/pointycastle.dart";
import "package:pointycastle/macs/hmac.dart";
import "package:pointycastle/digests/sha512.dart";
import "dart:typed_data";
import 'dart:convert';
import "package:hex/hex.dart";
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:http_auth/http_auth.dart';

/* For Binance and Coinbase (HmacSHA256)*/

_hmacSha256(String message, String secret) {
  var key = utf8.encode(secret);
  var msg = utf8.encode(message);
  var hmac = new Hmac(sha256, key);
  var signature = hmac.convert(msg).toString();

  return signature;
}

/* For Coinbase Pro (HmacSHA256 with base64 endode/decode)*/

_hmacSha256Base64(String message, String secret) {
  var base64 = new Base64Codec();
  var key = base64.decode(secret);
  var msg = utf8.encode(message);
  var hmac = new Hmac(sha256, key);
  var signature = hmac.convert(msg);

  return base64.encode(signature.bytes);
}

/* For Bittrex (HmacSHA512)*/

_hmacSha512(String message, String secret) {
  Uint8List hmacSHA512(Uint8List data, Uint8List key) {
    final _tmp = new HMac(new SHA512Digest(), 128)..init(new KeyParameter(key));
    return _tmp.process(data);
  }

  Uint8List msg = utf8.encode(message);
  Uint8List key = utf8.encode(secret);
  var digest = hmacSHA512(msg, key);
  var signature = HEX.encode(digest);

  return signature;
}

class Binance {
  String _apiKey;
  String _secret;
  String _base = 'https://api.binance.com';

  Binance(String apiKey, String secret) {
    this._apiKey = apiKey;
    this._secret = secret;
  }

  _response(request) async {
    try {
      var response;
      String timestamp =
          "timestamp=" + new DateTime.now().millisecondsSinceEpoch.toString();
      String query = request['query'] + '&' + timestamp;
      String signature = _hmacSha256(query, this._secret);
      var url = 'https://api.binance.com' +
          request['endPoint'] +
          "?" +
          query +
          '&signature=' +
          signature;

      if (request['method'] == 'GET') {
        response = await get(url, headers: {'X-MBX-APIKEY': this._apiKey});
      } else {
        response = await post(url, headers: {'X-MBX-APIKEY': this._apiKey});
      }
      return response;
    } on Exception {
      return null;
    }
  }

  getBalance() async {
    var request = {'endPoint': '/api/v3/account', 'query': '', 'method': 'GET'};
    var response = await _response(request);

    if (response != null && response.statusCode == 200) {
      var result = json.decode(response.body)['balances'];
      var balance = [];
      for (var res in result) {
        if (double.parse(res["free"]) > 0) {
          balance.add(res);
        }
      }

      return balance;
    }
    return null;

    /* return type: [{asset:asset, free:free, locked:locked}]
       just returns those assets where balance > 0 */
  }
}

class Coinbase {
  String _apiKey;
  String _secret;
  String _base = 'https://api.coinbase.com';

  Coinbase(String apiKey, String secret) {
    this._apiKey = apiKey;
    this._secret = secret;
  }

  _response(request) async {
    try {
      var timestamp = await get('https://api.coinbase.com/v2/time')
          .then((res) => json.decode(res.body))
          .then((res) => res['data']['epoch']);
      String query =
          timestamp.toString() + request['method'] + request['endPoint'];
      String signature = _hmacSha256(query, this._secret);
      var url = _base + request['endPoint'];

      var response = await get(url, headers: {
        'CB-ACCESS-KEY': this._apiKey,
        'CB-ACCESS-SIGN': signature,
        'CB-ACCESS-TIMESTAMP': timestamp.toString()
      });

      return response;
    } on Exception {
      return null;
    }
  }

  getBalance() async {
    var request = {'method': 'GET', 'endPoint': '/v2/accounts', 'body': ''};
    var response = await this._response(request);

    //print(response.body);
    if (response != null && response.statusCode == 200) {
      var result = json.decode(response.body)['data'];
      //print(result);
      var balance = [];
      for (var res in result) {
        if (double.parse(res['balance']['amount']) > 0) {
          balance.add(res['balance']);
        }
      }
      return balance;
    }
    return null;

    /* return type: [{amount:amount, currency:currency}]
       just returns those assets where balance > 0 */
  }
}

class CoinbasePro {
  String _apiKey;
  String _secret;
  String _passPhrase;
  String _base = 'https://api.pro.coinbase.com';

  CoinbasePro(String apiKey, String secret, String passPhrase) {
    this._apiKey = apiKey;
    this._secret = secret;
    this._passPhrase = passPhrase;
  }

  _response(request) async {
    try {
      var timestamp = await get('https://api.coinbase.com/v2/time')
          .then((res) => json.decode(res.body))
          .then((res) => res['data']['epoch']);
      String query = timestamp.toString() +
          request['method'] +
          request['endPoint'] +
          request['body'];
      String signature = _hmacSha256Base64(query, this._secret);
      var url = _base + request['endPoint'];

      var response = await get(url, headers: {
        'CB-ACCESS-KEY': this._apiKey,
        'CB-ACCESS-SIGN': signature,
        'CB-ACCESS-TIMESTAMP': timestamp.toString(),
        'CB-ACCESS-PASSPHRASE': this._passPhrase
      });
      return response;
    } on Exception {
      return null;
    }
  }

  getBalance() async {
    var request = {'method': 'GET', 'endPoint': '/accounts', 'body': ''};
    var response = await this._response(request);

    if (response != null && response.statusCode == 200) {
      var result = json.decode(response.body);
      //print(result);
      var balance = [];
      for (var res in result) {
        if (double.parse(res['balance']) > 0) {
          balance.add(res);
        }
      }
      return balance;
    }
    return null;

    /* return type: [{id:id, currency:currency, balance:balance,
                      available:available, hold:hold, profile_id:profile_id}]
       just returns those assets where balance > 0 */
  }
}

class HitBtc {
  String _apiKey;
  String _secret;
  String _base = 'https://api.hitbtc.com';

  HitBtc(String apiKey, String secret) {
    this._apiKey = apiKey;
    this._secret = secret;
  }

  _response(request) async {
    try {
      var client = BasicAuthClient(this._apiKey, this._secret);
      var response = await client.get(this._base + request);

      return response;
    } on Exception {
      return null;
    }
  }

  getBalance() async {
    var request = '/api/2/account/balance';
    var response = await this._response(request);

    //print(response.body);
    if (response != null && response.statusCode == 200) {
      var result = json.decode(response.body);
      // print(result);
      var balance = [];
      for (var res in result) {
        if (double.parse(res['available']) > 0) {
          balance.add(res);
        }
      }
      return balance;
    }
    return null;

    /* return type: [{currency:currency, available:available, 
                      reserved:reserved}]
       just returns those assets where balance > 0 */
  }
}

class Bittrex {
  String _apiKey;
  String _secret;
  String _base = 'https://api.bittrex.com/api/v1.1';

  Bittrex(String apiKey, String secret) {
    this._apiKey = apiKey;
    this._secret = secret;
  }

  _response(request) async {
    try {
      String timestamp =
          "nonce=" + new DateTime.now().millisecondsSinceEpoch.toString();
      String url =
          _base + request + '?' + 'apikey=$_apiKey' + '&' + 'nonce=$timestamp';
      String signature = _hmacSha512(url, this._secret);

      var response = await get(url, headers: {
        'apisign': signature,
      });

      return response;
    } on Exception {
      return null;
    }
  }

  getBalance() async {
    var request = '/account/getbalances';
    var response = await this._response(request);

    //print(response.body);
    if (response != null && response.statusCode == 200) {
      if (json.decode(response.body)['success'] == false) return null;
      var result = json.decode(response.body)['result'];
      // print(result);
      var balance = [];
      for (var res in result) {
        if (res['Balance'] > 0) {
          balance.add(res);
        }
      }
      return balance;
    }
    return null;

    /* return type: [{Currency:currency, Balance:balance, 
                      Available:available, Pending:pending,
                      CryptoAddress:cryptoaddress, Request:request,
                      Uuid:uuid}]
       just returns those assets where balance > 0 */
  }
}

/* fetches balances and formats them */

fetchBinance(exchange) async {
  final APIKEY = exchange['api_key'];
  final SECRET = exchange['secret'];

  final binance = new Binance(APIKEY, SECRET);
  var balances = await binance.getBalance();
  if (balances == null) {
    return null;
  }

  var wallets = [];

  for (var balance in balances) {
    wallets.add({
      'currency': balance['asset'],
      'amount': balance['free'],
    });
  }

  var data = {'balances': wallets, 'value': 0};
  data = await _calculateAmount(data);

  return data;
}

fetchCoinbase(exchange) async {
  final APIKEY = exchange['api_key'];
  final SECRET = exchange['secret'];

  final coinbase = new Coinbase(APIKEY, SECRET);
  var balances = await coinbase.getBalance();
  if (balances == null) {
    return null;
  }

  var wallets = [];

  for (var balance in balances) {
    wallets.add({
      'currency': balance['currency'],
      'amount': balance['amount'],
    });
  }

  var data = {'balances': wallets, 'value': 0};

  data = await _calculateAmount(data);
  print(data);

  return data;
}

fetchCoinbasePro(exchange) async {
  final APIKEY = exchange['api_key'];
  final SECRET = exchange['secret'];
  final PASSPHRASE = exchange['pass_phrase'];

  final coinbasePro = new CoinbasePro(APIKEY, SECRET, PASSPHRASE);
  var balances = await coinbasePro.getBalance();
  if (balances == null) {
    return null;
  }

  var wallets = [];

  for (var balance in balances) {
    wallets.add({
      'currency': balance['currency'],
      'amount': balance['balance'],
    });
  }

  var data = {'balances': wallets, 'value': 0};

  data = await _calculateAmount(data);

  return data;
}

fetchBittrex(exchange) async {
  final APIKEY = exchange['api_key'];
  final SECRET = exchange['secret'];

  final bittrex = new Bittrex(APIKEY, SECRET);
  var balances = await bittrex.getBalance();
  if (balances == null) {
    return null;
  }

  var wallets = [];

  for (var balance in balances) {
    //print(balance['Balance']);
    wallets.add({
      'currency': balance['Currency'],
      'amount': balance['Balance']
          .toStringAsFixed(9), //represents amount with 9 digits
    });
  }

  var data = {'balances': wallets, 'value': 0};

  data = await _calculateAmount(data);

  return data;
}

fetchHitBtc(exchange) async {
  final APIKEY = exchange['api_key'];
  final SECRET = exchange['secret'];

  final hitBtc = new HitBtc(APIKEY, SECRET);
  var balances = await hitBtc.getBalance();
  if (balances == null) {
    return null;
  }

  print(balances);

  var wallets = [];

  for (var balance in balances) {
    //print(balance['Balance']);
    wallets.add({
      'currency': balance['currency'],
      'amount': balance['available'],
    });
  }

  var data = {'balances': wallets, 'value': 0};

  data = await _calculateAmount(data);

  return data;
}

fetchMercatox(exchange) async {
  var balances = exchange['data']['balances'];
  var wallets = [];

  try {
    for (var balance in balances) {
      if (balance['currency'] == '' || balance['amount'] == '') return null;

      //print(balance['Balance']);
      wallets.add({
        'currency': balance['currency'],
        'amount': balance['amount'],
      });
    }

    var data = {'balances': wallets, 'value': 0};

    data = await _calculateAmount(data);

    return data;
  } on Exception {
    return null;
  }
}

/*calculates value of of all currencies in wallet in EUR */

_calculateAmount(data) async {
  //var url = 'https://api.cryptonator.com/api/ticker';
  var url = 'https://pro-api.coinmarketcap.com';
  //var result = [];
  double result = 0;
  var wallets = data['balances'];

  try {
    for (var wallet in wallets) {
      var currency = wallet['currency'];
      var amount = double.parse(wallet['amount']);
      var response = await get(
          url + '/v1/cryptocurrency/quotes/latest?symbol=$currency&convert=EUR',
          headers: {
            'X-CMC_PRO_API_KEY': 'c3f0b0d3-a892-4e5d-a913-30aefd092737'
          });

      double currencyPrice = 0;

      double eur;

      var icon;
      if (currency == 'EUR') {
        eur = amount;
        wallet['value'] = eur.toStringAsFixed(2);

        icon = _fetchIcons('EUR');
      } else {
        currencyPrice = json.decode(response.body)['data']['$currency']['quote']
            ['EUR']['price'];

        eur = currencyPrice * amount;
        wallet['value'] = eur.toStringAsFixed(2);
        var id = json.decode(response.body)['data']['$currency']['id'];
        icon = _fetchIcons(id);
      }
      result += eur;

      wallet['icon'] = icon;
    }

    data['value'] = result.toStringAsFixed(2);

    return data;
  } on Exception {
    return null;
  }
}

_fetchIcons(id) {
  if (id == 'EUR')
    return 'https://cdn3.iconfinder.com/data/icons/basicolor-money-finance/24/224_euro_eur_currency-512.png';

  return 'https://s2.coinmarketcap.com/static/img/coins/128x128/$id.png';
}
