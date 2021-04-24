import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/models/placeCart.dart';
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

class OpenCartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  List placeCart = [];
  double taxAmount = 0.0;
  int tax = 0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  double couponAmount = 0.0;
  double distance = 0.0;
  GlobalKey<ScaffoldState> scaffoldKey;
  Color iconColor = Colors.grey;
  String couponCheck = '';
  String restaurant_id;
  String appCharge='';
  int deliveryBoyFee=0;
  double totalDeliveryFee=0.0;
  
  int appChargeFee=0;
  OpenCartController() {
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
    print('lat...');
    print(double.parse(currentUser.value.lat));
    print(double.parse(currentUser.value.lng));
    print(carts[0].food.restaurant.latitude);
    print(carts[0].food.restaurant.longitude);

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
    }

    double restaurantLat;
    double restaurantLng;
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
          calculateDistance(userLat, userLng, restaurantLat, restaurantLng);
    }
    
    await getShipping(distance.toString());
    await getTax();
    await getInvoice();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getDouble('couponCode');
    if (prefs.containsKey('couponCode')) {
      await couponApply();
    }

    setState(() {});
  }

  couponApply() async { 
    SharedPreferences prefs = await SharedPreferences.getInstance();
   
    setState(() {
      total = total - prefs.getDouble('couponCode');
    });
    print('total here');
    print(total);
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
          this.totalDeliveryFee = double.parse(data["result"]["shipcost"]);
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
    try {
      if (data["resultcode"] == "200") {
        tax=int.parse(data["result"]["rate"]);
        if(tax!=0){
          setState((){ 
           taxAmount = (this.totalDeliveryFee) * tax / 100;
          });
        }     
          setState((){
            this.deliveryFee=(this.totalDeliveryFee-this.taxAmount);
          });        
         
      }
    
    } catch (e) {
      print(e);
    }
  }

  Future<void> getInvoice() async {
   Map data;
  final response = await http.get(Strings.baseUrl+'Dashboard/loadAppCharges');

  data=jsonDecode(response.body);
  print('app charge');
  print(data);
  try{
  if (data["resultcode"]=='200') {  
  setState(() { 
    this.appCharge=data["result"]["for_app"];
    this.appChargeFee=(((this.totalDeliveryFee*(int.parse(appCharge)))/100).round());
    this.deliveryBoyFee=(this.totalDeliveryFee-(this.appChargeFee+this.taxAmount)).round();
  });
  print('po'+this.totalDeliveryFee.toString());
  print('pop'+this.appChargeFee.toString());
  print('popp'+this.deliveryBoyFee.toString());
  print('poppp'+this.taxAmount.toString());
  return true;
  }} catch(e) {
  print(e);
  }
}

//   void doApplyCoupon(String code, {String message}) async {
//     print('coupon here');
//     print(code);
//     coupon = new Coupon.fromJSON({"code": code, "valid": null});
//     final Stream<Coupon> stream = await verifyCoupon(code);
//     stream.listen((Coupon _coupon) async {
//       coupon = _coupon;
//     }, onError: (a) {
//       print(a);
//       scaffoldKey?.currentState?.showSnackBar(SnackBar(
//         content: Text(S.of(context).verify_your_internet_connection),
//       ));
//     }, onDone: () {
//       listenForCarts();
// //      saveCoupon(currentCoupon).then((value) => {
// //          });
//     });
//   }

 

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
     ;
      final bool response = await placeOrder(
          placeCart,
          restaurant_id,
          total,
          prefs.getDouble('couponCode'),
          prefs.getString('coupon'),
          deliveryBoyFee,
          appChargeFee,
          taxAmount
          );
      if (response) {         
            carts.clear();
              
        Navigator.of(context).pushNamed('/success');
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.remove('couponCode');
        preferences.remove('coupon');
      }
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
