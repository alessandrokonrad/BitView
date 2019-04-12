// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/utility/fetch_exchange_data.dart';

void main() {
  test('Testing HmacSha512 for Bittrex', () async {
    var exchange = {
      'name': 'Bittrex',
      'icon': 'assets/bittrex.jpg',
      'api_key': 'Put your key here',
      'secret': 'Put your secret here',
      'data': null
    };

    var balances = await fetchBittrex(exchange);
    print(balances);
  });
}
