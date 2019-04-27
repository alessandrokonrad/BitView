import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRegisterManually extends StatefulWidget {
  ExchangeRegisterManually({Key key, this.exchange}) : super(key: key);
  final exchange;

  @override
  State<StatefulWidget> createState() {
    return ExchangeRegisterManuallyState(this.exchange);
  }
}

class ExchangeRegisterManuallyState extends State<ExchangeRegisterManually> {
  var _exchange;
  final formKey = GlobalKey<FormState>();
  final _currency = TextEditingController();
  final _amount = TextEditingController();
  var _currencyList = [];

  ExchangeRegisterManuallyState(exchange) {
    this._exchange = exchange;
  }

  _setExchangesList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var exchangesList = prefs.getString('exchangesList') ?? '[]';

    var exchangesJson = json.decode(exchangesList);
    exchangesJson.add({
      'name': 'Mercatox',
      'icon': 'assets/mercatox.png',
      'api_key': null,
      'secret': null,
      'data': {'balances': _currencyList}
    });
    exchangesList = json.encode(exchangesJson);
    prefs.setString('exchangesList', exchangesList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text(_exchange['name']),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: _currencyList.length + 1,
                  itemBuilder: (context, i) {
                    return Container(
                      padding: EdgeInsets.only(bottom: 15, top: 10),
                      child: _inputListTile(i),
                    );
                  }),
            ),
            RaisedButton(
              color: Theme.of(context).accentColor,
              child: Text(
                "Add",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (_currencyList.length > 0) {
                  print(_currencyList);
                  _setExchangesList();

                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
            )
          ],
        ));
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _currency.dispose();
    _amount.dispose();
    super.dispose();
  }

  _inputListTile(index) {
    if (_currencyList.length > index)
      return Center(
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 100,
          height: 50,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Currency',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
            style: TextStyle(color: Colors.white),
            controller: _currency,
            autofocus: true,
          ),
        ),
        Container(
          width: 100,
          height: 50,
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              fillColor: Colors.white,
              labelText: 'Amount',
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
            ),
            controller: _amount,
          ),
        ),
        ButtonTheme(
          minWidth: 20,
          height: 30,
          child: RaisedButton(
            color: Theme.of(context).accentColor,
            onPressed: () {
              setState(() {
                _currencyList.add({
                  'currency': _currency.text,
                  'amount': _amount.text,
                });
              });

              _currency.clear();
              _amount.clear();
            },
            child: Text(
              '+',
              style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}
