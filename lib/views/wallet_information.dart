import 'package:flutter/material.dart';

class WalletInformation extends StatelessWidget {
  const WalletInformation({Key key, this.exchange}) : super(key: key);

  final exchange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          forceElevated: true,
          elevation: 4,
          backgroundColor: Theme.of(context).backgroundColor,
          expandedHeight: 230,
          flexibleSpace: Container(
            child: Center(
                child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 60),
                ),
                Image.asset(
                  exchange['icon'],
                  width: 50,
                  height: 50,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                ),
                Text(exchange['data']['value'] + ' €',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                Padding(
                    padding: EdgeInsets.all(25),
                    child: Divider(
                      color: Colors.white,
                    ))
              ],
            )),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.all(20),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, i) {
            var exchangeBalances = exchange['data']['balances'][i];
            return Container(
                padding: EdgeInsets.only(bottom: 30, left: 45, right: 45),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Image.network(
                      exchangeBalances['icon'],
                      width: 30,
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                    ),
                    Text(
                      exchangeBalances['currency'],
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                    ),
                    Text(
                      exchangeBalances['amount'],
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                    ),
                    Text(exchangeBalances['value'] + ' €',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold))
                  ],
                ));
          }, childCount: exchange['data']['balances'].length),
        )
      ],
    ));
  }
}
