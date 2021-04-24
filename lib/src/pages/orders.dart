import 'dart:async';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/order_controller.dart';
import '../elements/EmptyOrdersWidget.dart';
import '../elements/OrderItemWidget.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/user_repository.dart';
import '../models/myorder.dart';
import '../repository/order_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrdersWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  OrdersWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _OrdersWidgetState createState() => _OrdersWidgetState();
}

class _OrdersWidgetState extends StateMVC<OrdersWidget> {
  OrderController _con;
  Future<MyOrder> _orderList;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  _OrdersWidgetState() : super(OrderController()) {
    _con = controller;
  }

  Future<void> postCancel(String id) async {
    Map data;
    final http.Response response = await http.post(
      Strings.baseUrl + 'Orders/orderCancel',
      body: {'orderid': id, 'app_user_id': currentUser.value.id},
    );

    data = jsonDecode(response.body);
    try {
      if (data["resultcode"] == "200") {
        setState(() {
          _orderList = getMyOrders();
        });
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _orderList = getMyOrders();
    });

    return null;
  }

  _loadApi() {
    if(mounted){
    setState(() {
      _orderList = getMyOrders();
    });
    }
  }

  @override
  void initState() {
    const fiveSeconds = const Duration(seconds: 2);
    /*if (mounted)*/
      _orderList = getMyOrders();
    // Timer.periodic(fiveSeconds, (Timer t) => _loadApi());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // key: _con.scaffoldKey,
        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
            onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).my_orders,
            style: Theme.of(context)
                .textTheme
                .headline6
                .merge(TextStyle(letterSpacing: 1.3)),
          ),
          actions: <Widget>[
            new ShoppingCartButtonWidget(
                iconColor: Theme.of(context).hintColor,
                labelColor: Theme.of(context).accentColor),
          ],
        ),
        body: !currentUser.value.auth
            ? PermissionDeniedWidget()
            : RefreshIndicator(
                key: refreshKey,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  child: FutureBuilder<MyOrder>(
                      future: _orderList,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.separated(
                            itemCount: snapshot.data.result.length,
                            itemBuilder: (context, index) {
                              var out = snapshot.data.result[index];
                              return OrderItemWidget(
                                  paymenttype: out.paymenttype ?? 'default',
                                  orderid: out.orderid ?? 'default',
                                  ordertime: out.ordertime ?? 'default',
                                  status: out.status ?? 'default',
                                  total: out.total ?? 'default',
                                  deliveryFee: out.shipping,
                                  deliveryboyid: out.deliverboyid ?? '',
                                  appcharge: out.appcharge,
                                  dmobile: out.dmobile,
                                  cancel: () => postCancel(out.orderid));
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 20);
                            },
                          );
                        }
                        return Center(child: CircularProgressIndicator());
                      }),
                ),
                onRefresh: refreshList,
              ));
  }
}
