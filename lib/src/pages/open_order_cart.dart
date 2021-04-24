import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/models/coupon_model.dart';
import 'package:food_delivery_app/src/models/open_cart.dart';
import 'package:food_delivery_app/src/models/user.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/CartItemWidget.dart';
import '../elements/EmptyCartWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../models/coupon_model.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../repository/user_repository.dart' as userRepo;

var countcart = 0;

class OpenOrderCart extends StatefulWidget {
  final String restaurantId;
  final String lat;
  final String lng;

  const OpenOrderCart({
    Key key,
    @required this.restaurantId,
    this.lat,
    this.lng,
  }) : super(key: key);

  @override
  _OpenOrderCartState createState() => _OpenOrderCartState();
}

class _OpenOrderCartState extends State<OpenOrderCart> {
  final myController = TextEditingController();

  double deliveryFee = 0.0;
  bool loading = false;
  List openCart = [];
  CartController _con;
  double distance = 0.0;
  CouponModel couponObj;
  String item = '';
  bool loadingCard = false;
  int app_percentage;
  int tax_percentage;
  double app_fee;
  double delivery_boy_fee;
  double subtotal_delivery_charge = 0.0;
  double tax = 0.0;
  double totaldeliveryCharge;
  double deliveryCharge;

  getShippingCharge() async {
    double userLat;
    double userLng;
    print("lat" + currentUser.value.lat);
    print("lng" + currentUser.value.lng);
    if (currentUser.value.lat != null && currentUser.value.lng != null) {
      userLat = double.parse(currentUser.value.lat);
      userLng = double.parse(currentUser.value.lng);
    }

    double restaurantLat;
    double restaurantLng;
    if (widget.lat != null && widget.lng != null) {
      restaurantLat = double.parse(widget.lat);
      restaurantLng = double.parse(widget.lng);
    }

    if (userLat != null &&
        userLng != null &&
        restaurantLat != null &&
        restaurantLat != "" &&
        restaurantLng != null &&
        restaurantLng != "") {
      distance =
          calculateDistance(userLat, userLng, restaurantLat, restaurantLng);
    }
    await getShipping(distance.toString());
    await getTax();
    await getPercentage();
    setState(() {
      app_fee = (app_percentage * deliveryCharge) / 100;
      delivery_boy_fee = ((100 - app_percentage) * deliveryCharge) / 100;
      subtotal_delivery_charge = app_fee + delivery_boy_fee;
      tax = (tax_percentage * subtotal_delivery_charge) / 100;
      totaldeliveryCharge = subtotal_delivery_charge + tax;
      // total = totaldeliveryCharge + subTotal;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    print('cal lat and lng');
    print(lat1);
    print(lon1);
    print(lat1);
    print(lon1);

    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    print(12742 * asin(sqrt(a)));
    return 12742 * asin(sqrt(a));
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

  @override
  void initState() {
    print('ar' + openCart.length.toString());
    print('idddd' + widget.restaurantId);
    getShippingCharge();
    super.initState();
  }

  Widget _buildPopupDialog(BuildContext context) {
    return new AlertDialog(
      backgroundColor: Colors.orange[100],
      title: const Text('Add Item'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(4),
              child: TextField(
                controller: myController,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Item',
                    fillColor: Colors.black,
                    hintText: 'Enter your Items'),
              )),
          // Increment()
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            print(myController.text);
            var temp = {
              'itemsquantity': countcart.toString(),
              'itemsname': myController.text,
            };
            print("add" + myController.text);
            if (myController.text != "") {
              setState(() {
                openCart.add(temp);
                item = myController.text;
                loadingCard = true;
              });
            }
            print(openCart.length);

            Navigator.of(context).pop();
          },
          textColor: Colors.black,
          child: const Text('ADD'),
        ),
      ],
    );
  }

  Future<void> placeOrder() async {
    setState(() {
      loading = true;
    });
    User _user = userRepo.currentUser.value;
    if (!_user.auth) {
      return false;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var id = prefs.getString('id');
    Map data;
    String address = _user.address;
    String latitude = _user.lat;
    String langitude = _user.lng;

    print(id);
    print(widget.restaurantId);
    print(jsonEncode(openCart));
    print(address);
    print(latitude);
    print(langitude);
    print(deliveryFee.toString());

    final String url =
        '${GlobalConfiguration().getValue('local_url')}Orders/createOrder';
    final client = new http.Client();
    final response = await client.post(url,
        // body: json.encode(cart.toMap()),
        body: {
          'app_user_id': id,
          'pickup_point_id': widget.restaurantId,
          'items1': jsonEncode(openCart),
          'paymenttype': 'COD',
          'delivery_address': address,
          'delivery_lat': latitude,
          'delivery_lang': langitude,
          'total': '0',
          'coupon': '0',
          'couponprice': '0',
          'shipping': totaldeliveryCharge.toString(),
          'app_charge': app_fee.toString(),
          'tax': tax.toString()
        });
    data = jsonDecode(response.body);
    print('pu' + data.toString());
    print(response.body);
    try {
      if (data["resultcode"] == "200") {
        setState(() {
          loading = false;
        });
        Navigator.of(context).pushReplacementNamed('/success');
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: _con.scaffoldKey,
      bottomNavigationBar: Container(
        height: 150,
        child: Card(
            child: Column(
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Delivery Charge', style: TextStyle(fontSize: 20)),
                    Text(subtotal_delivery_charge.toString(),
                        style: TextStyle(fontSize: 18))
                  ],
                )),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tax', style: TextStyle(fontSize: 20)),
                    Text(tax.toString(), style: TextStyle(fontSize: 18))
                  ],
                )),
            !loading
                ? RaisedButton(
                    onPressed: () {
                      placeOrder();
                    },
                    child: const Text('Place Order',
                        style: TextStyle(fontSize: 20)),
                  )
                : CircularProgressIndicator(),
          ],
        )),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).cart,
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          // ListView.builder(
          //     padding: const EdgeInsets.all(8),
          //     itemCount: openCart.length,
          //     itemBuilder: (BuildContext context, int index) {
          //       return Expanded(
          //           child: Card(
          //               child: Container(
          //         padding: const EdgeInsets.all(10),
          //         child: Row(
          //           children: [
          //             Expanded(
          //                 child: Text(openCart[index]["itemsname"].toString())),
          //           ],
          //         ),
          //       )));
          //     }),
          loadingCard
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    child: Card(
                        child: Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(child: Text(item)),
                        ],
                      ),
                    )),
                  ),
                )
              : Container(),
          Container(
            margin: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.bottomRight,
            child: openCart.length == 0
                ? FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            _buildPopupDialog(context),
                      );
                      //  Navigator.of(context).pushNamed('/Food', arguments: RouteArgument(id: food.id, heroTag: this.heroTag,restaurantId: food.restaurant.id));
                    },
                    child: Icon(Icons.add),
                    backgroundColor: Colors.orange[900],
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}

class Increment extends StatefulWidget {
  @override
  _IncrementState createState() => _IncrementState();
}

class _IncrementState extends State<Increment> {
  int count = 1;

  incrementQuantity() {
    print('increccc' + count.toString());
    if (count <= 99) {
      setState(() {
        count = count + 1;
        countcart = count;
      });
    }
  }

  decrementQuantity() {
    print('decre' + count.toString());
    if (count > 1) {
      setState(() {
        count = count - 1;
        countcart = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            S.of(context).quantity,
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              onPressed: () {
                decrementQuantity();
              },
              iconSize: 30,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              icon: Icon(Icons.remove_circle_outline),
              color: Theme.of(context).hintColor,
            ),
            Text('$count', style: Theme.of(context).textTheme.subtitle1),
            IconButton(
              onPressed: () {
                incrementQuantity();
              },
              iconSize: 30,
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              icon: Icon(Icons.add_circle_outline),
              color: Theme.of(context).hintColor,
            )
          ],
        ),
      ],
    );
  }
}
