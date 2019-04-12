import 'package:flutter/material.dart';
import './exchange_registering.dart';
import './exchange_register_manually.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExchangeSelect extends StatelessWidget {
  final _exchangesList = [
    {
      'name': 'Coinbase',
      'icon': 'assets/coinbase.png',
      'api_key': null,
      'secret': null,
      'data': null
    },
    {
      'name': 'Coinbase Pro',
      'icon': 'assets/coinbase_pro.jpg',
      'api_key': null,
      'secret': null,
      'pass_phrase': null,
      'data': null
    },
    {
      'name': 'Bittrex',
      'icon': 'assets/bittrex.jpg',
      'api_key': null,
      'secret': null,
      'data': null
    },
    {
      'name': 'Binance',
      'icon': 'assets/binance.png',
      'api_key': null,
      'secret': null,
      'data': null
    },

    // TODO: Implement Mercatox
    {
      'name': 'Mercatox',
      'icon': 'assets/mercatox.png',
      'api_key': null,
      'secret': null,
      'data': null
    }
  ];

  _getExchangesList(exchange) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String exchangesString = prefs.getString('exchangesList') ?? '[]';
    if (exchangesString == '[]') return true;

    var storedExchanges = json.decode(exchangesString);
    for (int i = 0; i < storedExchanges.length; i++) {
      if (exchange['name'] == storedExchanges[i]['name']) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text("Select Exchange"),
      ),
      body: ListView.builder(
        itemCount: _exchangesList.length,
        itemBuilder: (context, i) {
          var exchange = _exchangesList[i];

          return InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () async {
              var flag = await _getExchangesList(exchange);
              if (flag)
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  if (exchange['name'] == 'Mercatox')
                    return ExchangeRegisterManually(exchange: exchange);
                  return ExchangeRegister(exchange: exchange);
                }));
            },
            child: Container(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      Image.asset(exchange['icon'], width: 50, height: 50),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                      ),
                      Text(
                        exchange['name'],
                        style: TextStyle(fontSize: 22.0, color: Colors.white),
                      )
                    ],
                  )),
            ),
          );
        },
      ),
    );
  }
}
