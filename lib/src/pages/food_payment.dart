import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../controllers/cart_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../models/route_argument.dart';
import '../elements/CartBottomDetailsWidget.dart';

class FoodPayment extends StatefulWidget {
  final RouteArgument routeArgument;

  FoodPayment({Key key, this.routeArgument}) : super(key: key);

  @override
  _FoodPaymentState createState() => _FoodPaymentState();
}

class _FoodPaymentState extends StateMVC<FoodPayment> {
  CartController _con;

  _FoodPaymentState() : super(CartController()) {
    _con = controller;
  }

  bool showvalue = false;
  bool loading;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:Scaffold(
        body: Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: this.showvalue,
              onChanged: (bool value) {
                setState(() {
                  this.showvalue = value;
                });
              },
            ),
            Text('Pay on Delivery')
          ],
        ),
        CartBottomDetailsWidget(con: _con)
        // RaisedButton(
        //   textColor: Colors.white,
        //   color: Colors.blue,
        //   child: Text('Place Order'),
        //   onPressed: () {
        //     loading=true;
        

        //   },
        // ),
      //  loading == ''  ? Text('') :loading ? CircularProgressIndicator():Text('OrderPlaced!!')
          
      ],
    )));
  }
}
