import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/pages/courier_payment.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show cos, sqrt, asin;
import 'dart:math';
import 'package:food_delivery_app/generated/l10n.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PickupCourier extends StatefulWidget {
  @override
  _PickupCourierState createState() => _PickupCourierState();
}

double roundDouble(double value, int places) {
  double mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
}

class _PickupCourierState extends State<PickupCourier> {
  final productName = TextEditingController();
  final productDescription = TextEditingController();
  bool loading = false;
  String deliveryAddress = 'Delivery point Address';
  String pickupAddress = 'Pickup point Address';
  double pickuplat;
  double pickuplng;
  double deliverylat;
  double deliverylng;
  double distance;
  int app_percentage;
  int tax_percentage;
  double app_fee;
  double delivery_boy_fee;
  double subtotal_delivery_charge;
  double tax;
  double totaldeliveryCharge;
  double deliveryCharge;
  bool pickupSelect = false;
  bool deliverySelect = false;
  bool distanceCal = false;
  bool submitLoading=false;
  bool enable = true;

  void getpickupAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey:
              'AIzaSyB38zgsBuf31H8icWOX5sKQGXXb84JnDhE', // Put YOUR OWN KEY here.
          onPlacePicked: (result) {
            print(result);
            setState(() {
              this.pickupAddress = result.formattedAddress;
              this.pickuplat = result.geometry.location.lat;
              this.pickuplng = result.geometry.location.lng;
              this.pickupSelect = true;
            });

            Navigator.of(context).pop();
          },
          initialPosition: LatLng(-33.8567844, 151.213108),
          useCurrentLocation: true,
        ),
      ),
    );
  }

  Future<void> postOrder() async {
    Map data;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final http.Response response =
        await http.post(Strings.baseUrl + 'Courrier/addCourier', body: {
      'app_user_id': prefs.getString('id'),
      'Goods_name': productName.text,
      'total': totaldeliveryCharge.toString(),
      'paymenttype': 'COD',
      'pickup_address': pickupAddress,
      'pickup_lat': pickuplat.toString(),
      'pickup_lng': pickuplng.toString(),
      'delivery_address': deliveryAddress,
      'delivery_lat': deliverylat.toString(),
      'delivery_lang': deliverylng.toString(),
      'shipping': totaldeliveryCharge.toString(),
      'app_charge': app_fee.toString(),
      'tax': tax.toString()
    });

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

  void getdeliveryAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey:
              'AIzaSyB38zgsBuf31H8icWOX5sKQGXXb84JnDhE', // Put YOUR OWN KEY here.
          onPlacePicked: (result) {
            print(result.geometry);
            setState(() {
              this.deliveryAddress = result.formattedAddress;
              this.deliverylat = result.geometry.location.lat;
              this.deliverylng = result.geometry.location.lng;
              this.deliverySelect = true;
            });

            Navigator.of(context).pop();
          },
          initialPosition: LatLng(-33.8567844, 151.213108),
          useCurrentLocation: true,
        ),
      ),
    );
  }

  void getDistance() {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((this.deliverylat - this.pickuplat) * p) / 2 +
        c(this.pickuplat * p) *
            c(this.deliverylat * p) *
            (1 - c((this.deliverylng - this.pickuplng) * p)) /
            2;

    setState(() {
      this.distance = 12742 * asin(sqrt(a));
    });
    getShipping(distance.toString());
  }

  Future<void> getShipping(String shipping) async {
    Map data;
    final http.Response response = await http.get(
      Strings.baseUrl + 'Shipping/loadShipping?distance=$shipping&type=amount',
    );
    data = jsonDecode(response.body);
    try {
      if (data["resultcode"] == "200") {
        setState(() {
          this.deliveryCharge = double.parse(data["result"]["shipcost"]);
        });
        await getPercentage();
        await getTax();

        setState(() {
          app_fee = (app_percentage * deliveryCharge) / 100;
          delivery_boy_fee = ((100 - app_percentage) * deliveryCharge) / 100;
          subtotal_delivery_charge = app_fee + delivery_boy_fee;
          tax = (tax_percentage * subtotal_delivery_charge) / 100;
          totaldeliveryCharge = subtotal_delivery_charge + tax;
          this.distanceCal = true;
          this.enable = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getPercentage() async {
    Map data;
    final response =
        await http.get(Strings.baseUrl + 'Dashboard/loadAppCharges');

    data = jsonDecode(response.body);
    print('check1' + data["result"]["for_app"]);
    try {
      if (data["resultcode"] == '200') {
        setState(() {
          this.app_percentage = int.parse(data["result"]["for_app"]);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getTax() async {
    Map data;
    final http.Response response = await http.get(
      Strings.baseUrl + 'Tax/loadTax',
    );
    data = jsonDecode(response.body);
    print('check2' + data.toString());
    try {
      if (data["resultcode"] == "200") {
        setState(() {
          tax_percentage = int.parse(data["result"]["rate"]);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.amber[50],
        appBar: AppBar(
          title: Text('Courier Details'),
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: TextField(
                        controller: productName,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Courier Item Name",
                        ),
                      ),
                    ),
                   
                    SizedBox(height: 10),
                    GestureDetector(
                        onTap: () {
                          enable ? getpickupAddress() : null;
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                              child: Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(this.pickupAddress),
                          )),
                        )),
                    SizedBox(height: 10),
                    GestureDetector(
                        onTap: () {
                          enable ? getdeliveryAddress() : null;
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Card(
                              child: Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(this.deliveryAddress),
                          )),
                        )),
                    SizedBox(height: 10),
                    if (pickupSelect && deliverySelect && !submitLoading)
                      RaisedButton(
                        textColor: Colors.white,
                        color: Theme.of(context).accentColor,
                        child: Text(S.of(context).submit),
                        onPressed: () {
                          setState(() {
                            this.submitLoading=true;
                          });
                          getDistance();
                        },
                      ),
                    // Text(distance.toString()),
                    if (distanceCal && !loading)
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delivery Charge',
                                    style: TextStyle(fontSize: 18)),
                                Text(
                                    '' +
                                        roundDouble(subtotal_delivery_charge, 2)
                                            .toString(),
                                    style: TextStyle(fontSize: 18))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tax', style: TextStyle(fontSize: 18)),
                                Text('' + roundDouble(tax, 2).toString(),
                                    style: TextStyle(fontSize: 18))
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total', style: TextStyle(fontSize: 18)),
                                Text(
                                    '' +
                                        roundDouble(
                                                subtotal_delivery_charge + tax,
                                                2)
                                            .toString(),
                                    style: TextStyle(fontSize: 18))
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(value: true, onChanged: null),
                                Text('Pay on Delivery')
                              ],
                            ),
                            Row(
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
                          ],
                        ),
                      ),
                      if(loading)
                     CircularProgressIndicator()
                  ],
                )),
          ),
        ));
  }
}
