import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CourierPayment extends StatefulWidget {
  final String productName;
  final String productDescription;
  final String pickupAddress;
  final String pickupLat;
  final String pickupLng;
  final String deliveryAddress;
  final String deliverylLat;
  final String deliveryLng;
  final String deliveryCharge;
  final String appCharge;
  final String tax;

  CourierPayment(
      {this.productName,
      this.productDescription,
      this.pickupAddress,
      this.pickupLat,
      this.pickupLng,
      this.deliveryAddress,
      this.deliverylLat,
      this.deliveryLng,
      this.deliveryCharge,
      this.appCharge,
      this.tax});

  @override
  _CourierPaymentState createState() => _CourierPaymentState();
}

class _CourierPaymentState extends State<CourierPayment> {
  bool showvalue = false;
  bool loading = false;

  Future<void> postOrder() async {
    Map data;
    SharedPreferences prefs = await SharedPreferences.getInstance();
 
    final http.Response response =
        await http.post(Strings.baseUrl + 'Courrier/addCourier', body: {
      'app_user_id': prefs.getString('id'),
      'Goods_name': widget.productName,
      'total': widget.deliveryCharge,
      'paymenttype': 'COD',
      'pickup_address': widget.pickupAddress,
      'pickup_lat': widget.pickupLat,
      'pickup_lng': widget.pickupLng,
      'delivery_address': widget.deliveryAddress,
      'delivery_lat': widget.deliverylLat,
      'delivery_lang': widget.deliveryLng,
      'shipping': widget.deliveryCharge,
      'app_charge': widget.appCharge,
      'tax': widget.tax
    });
    print("orderPlaced");
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        loading = false;
      });
      print('1');
      print(response.body);
      data = jsonDecode(response.body);
      if (data["resultcode"] == "200") {
        Navigator.of(context).pushReplacementNamed('/courierSuccess');
      }
    } else {
      setState(() {
        loading = false;
      });
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                title: const Text('Cart'),
             ),
                body: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value:true,
                  onChanged: (bool value) {
                    setState(() {
                      this.showvalue = value;
                    });
                  },
                ),
                Text('Pay on Delivery')
              ],
            ),
            loading == false
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                          textColor: Colors.white,
                          color: Theme.of(context).accentColor,
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed('/courierHome');
                          }),
                      SizedBox(width: 20),
                      RaisedButton(
                        textColor: Colors.white,
                        color: Theme.of(context).accentColor,
                        child: Text('Place Order'),
                        onPressed: () {
                          setState(() {
                            loading = true;
                          });
                          postOrder();
                        },
                      ),
                    ],
                  )
                : CircularProgressIndicator()

            //  loading == ''  ? Text('') :loading ? CircularProgressIndicator():Text('OrderPlaced!!')
          ],
        ))));
  }
}
