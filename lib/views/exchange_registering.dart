import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRegister extends StatefulWidget {
  ExchangeRegister({Key key, this.exchange}) : super(key: key);
  final exchange;

  @override
  State<StatefulWidget> createState() {
    return ExchangeRegisterState(this.exchange);
  }
}

class ExchangeRegisterState extends State<ExchangeRegister> {
  var _exchange;
  final formKey = GlobalKey<FormState>();
  String _apiKey, _secret, _passPhrase;

  ExchangeRegisterState(exchange) {
    this._exchange = exchange;
  }

  _setExchangesList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var exchangesList = prefs.getString('exchangesList') ?? '[]';

    var exchangesJson = json.decode(exchangesList);
    exchangesJson.add(this._exchange);
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
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Api Key',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                    style: TextStyle(color: Colors.white),
                    onSaved: (input) => _apiKey = input,
                    autofocus: true,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Secret',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                    onSaved: (input) => _secret = input,
                  ),
                  this._exchange['name'] == 'Coinbase Pro'
                      ? Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Passphrase',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white)),
                            ),
                            style: TextStyle(color: Colors.white),
                            onSaved: (input) => _passPhrase = input,
                          ))
                      : Padding(
                          padding: EdgeInsets.all(0),
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: RaisedButton(
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();
                              this._exchange['api_key'] = _apiKey;
                              this._exchange['secret'] = _secret;
                              if (this._exchange['name'] == 'Coinbase Pro')
                                this._exchange['pass_phrase'] = _passPhrase;

                              _setExchangesList();

                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                          },
                          child: Text(
                            'Add',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
