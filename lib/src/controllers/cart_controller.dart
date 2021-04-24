import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/models/placeCart.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:math' show cos, sqrt, asin;
import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../models/coupon_model.dart';
import '../repository/cart_repository.dart';
import '../repository/coupon_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  List placeCart = [];
  int app_percentage;
  int tax_percentage;
  double app_fee;
  double delivery_boy_fee;
  double subtotal_delivery_charge;
  double tax;
  double totaldeliveryCharge;
  double deliveryCharge;

  double totalDeliveryFee = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  double couponAmount = 0.0;
  int distance = 0;
  GlobalKey<ScaffoldState> scaffoldKey;
  Color iconColor = Colors.grey;
  String couponCheck = '';
  String restaurant_id;
  String appCharge = '';

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String message}) async {
    carts.clear();
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      if (!carts.contains(_cart)) {
        setState(() {
          coupon = _cart.food.applyCoupon(coupon);
          carts.add(_cart);
          String name = _cart.food.name;
          String id = _cart.food.id;
          String quantity = _cart.quantity.toString();
          String price = _cart.food.price.toString();
          String total = (_cart.food.price * _cart.quantity).toString();
          restaurant_id = (_cart.food.restaurant.id).toString();
          var temp = {
            'itemname': name,
            'itemquantity': quantity,
            'itemprice': price,
            'itemid': id,
            'itemtotal': total,
          };
          placeCart.add(temp);
        });
      }
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (carts.isNotEmpty) {
        calculateSubtotal();
      }
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
      onLoadingCartDone();
    });
  }

  void onLoadingCartDone() {}

  void listenForCartsCount({String message}) async {
    final int count = await getCartCount();
    setState(() {
      this.cartCount = count;
    });
  }

  Future<void> refreshCarts() async {
    setState(() {
      carts = [];
    });
    listenForCarts(message: S.of(context).carts_refreshed_successfuly);
  }

  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts.remove(_cart);
    });
    removeCart(_cart).then((value) {
      calculateSubtotal();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(
            S.of(context).the_food_was_removed_from_your_cart(_cart.food.name)),
      ));
    });
  }

  void calculateSubtotal() async {

    double cartPrice = 0;
    subTotal = 0;
    carts.forEach((cart) {
      cartPrice = cart.food.price;
      cart.extras.forEach((element) {
        cartPrice += element.price;
      });
      cartPrice *= cart.quantity;
      subTotal += cartPrice;
    });
    double userLat;
    double userLng;
    if (currentUser.value.lat != null && currentUser.value.lng != null) {
      userLat = double.parse(currentUser.value.lat);
      userLng = double.parse(currentUser.value.lng);
      print(
          "print lat and lng" + userLat.toString() + "," + userLng.toString());
    }

    double restaurantLat;
    double restaurantLng;
    print("Carts Length" + carts.length.toString());
    /*for(var i=0;i<carts.length;i++){
      print("resLatAndLng"+carts[i].food.restaurant.latitude+","+carts[i].food.restaurant.longitude);
    }*/

    if (carts[0].food.restaurant.latitude != null &&
        carts[0].food.restaurant.longitude != null) {
      restaurantLat = double.parse(carts[0].food.restaurant.latitude);
      restaurantLng = double.parse(carts[0].food.restaurant.longitude);
    }

    if (userLat != null &&
        userLng != null &&
        restaurantLat != null &&
        restaurantLat != "" &&
        restaurantLng != null &&
        restaurantLng != "") {
      distance =
          calculateDistance(userLat, userLng, restaurantLat, restaurantLng)
              .round();
      print("distance" + distance.toString());
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getDouble('couponCode');
    if (prefs.containsKey('couponCode')) {
      await couponApply();
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
      total = totaldeliveryCharge + subTotal;
    });
    // total = subTotal  + deliveryFee;

    setState(() {});
  }

  couponApply() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int couponamount = prefs.getDouble('couponCode').toInt();
    prefs.setDouble('promotionAmt', prefs.getDouble('couponCode'));

    int totalAmount = subTotal.toInt();
    if (couponamount < totalAmount) {
         int cal = totalAmount - couponamount;
      setState(() {    
        this.subTotal = cal.toDouble();
      });
      await prefs.setString("couponApplied", "1");
    } else {
      await prefs.setString("couponApplied", "0");
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {


    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    print(12742 * asin(sqrt(a)));
    return 12742 * asin(sqrt(a));
  }

  Future<void> getShipping(String shipping) async {
    print('shppdes' + shipping);
    Map data;
    final http.Response response = await http.get(
      Strings.baseUrl + 'Shipping/loadShipping?distance=$shipping&type=amount',
    );
    data = jsonDecode(response.body);
    print('resdata' + data.toString());
    try {
      if (data["resultcode"] == "200") {
        setState(() {
          deliveryCharge = double.parse(data["result"]["shipcost"]);
        });
      }
    } catch (e) {
      print(e);
    }

    print('product delivery info');
    print(shipping);
    print(deliveryFee);
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

  void doApplyCoupon(String code, {String message}) async {
    double deduct = 0.0;
    String id=carts.first.food.restaurant.id;
    final CouponModel couponResponse = await verifyCoupon(code,id);
    if (couponResponse.type == 'amount') {
      deduct = double.parse(couponResponse.rate);
    } else {
      deduct = ((double.parse(couponResponse.rate)) * this.subTotal) / 100;
    }
    print('deduct'+deduct.toString()+'sub'+this.subTotal.toString());
 
    if (couponResponse.valid) {
      setState(() {
        this.couponAmount = deduct;
        iconColor = Colors.green;
        couponCheck = 'Coupon Applied';
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('couponCode', deduct);
      await prefs.setString('coupon', code);
      await calculateSubtotal();
    } else {
      setState(() {
        iconColor = Colors.redAccent;
        couponCheck = 'Coupon Invalid';
      });
    }
  }

  incrementQuantity(Cart cart) {
    if (cart.quantity <= 99) {
      ++cart.quantity;
      // updateCart(cart);
      // listenForCarts();
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      // updateCart(cart);
      // listenForCarts();
      calculateSubtotal();
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

  Future<void> goCheckout(BuildContext context) async {
    if (!currentUser.value.profileCompleted()) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).completeYourProfileDetailsToContinue),
        action: SnackBarAction(
          label: S.of(context).settings,
          textColor: Theme.of(context).accentColor,
          onPressed: () {
            Navigator.of(context).pushNamed('/Settings');
          },
        ),
      ));
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.getDouble('couponCode');
      await getPercentage();
      final bool response = await placeOrder(
          placeCart,
          restaurant_id,
          total,
          prefs.getDouble('promotionAmt'),
          prefs.getString('coupon'),
          totaldeliveryCharge.round(),
          app_fee.round(),
          tax);
      if (response) {
        carts.clear();
        Navigator.of(context).pushNamed('/success');
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.remove('couponCode');
        preferences.remove('coupon');
      }
      // Navigator.of(context).pushNamed('/success');
      // placeOrder(placeCart,restaurant_id);

    }
  }

  Color getCouponIconColor() {
    return iconColor;
  }

  String getCouponStatus() {
    return couponCheck;
  }
}
