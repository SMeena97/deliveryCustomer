import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Cart>> getCart() async {
  User _user = userRepo.currentUser.value;
  print('user_id'+_user.id);
  if (!_user.auth) {
    return new Stream.value(null);
  }
  // final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('local_url')}AddtoCart/loadViewAddCart?user_id=${_user.id}';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Cart.fromJSON(data);
  });
}

Future<int> getCartCount() async {
  Map data;
  List temp = [];
  User _user = userRepo.currentUser.value;
  if (!_user.auth) {
    return 0;
  }
  final String url =
      '${GlobalConfiguration().getValue('local_url')}AddtoCart/loadViewAddCart?user_id=${_user.id}';
  final response = await http.get(url);
  data = jsonDecode(response.body);
  temp = data["result"];
  return temp.length;
}

Future<Cart> addCart(Cart cart, bool reset) async {
  User _user = userRepo.currentUser.value;
  if (!_user.auth) {
    return new Cart();
  }
  cart.userId = _user.id;
  final String url =
      '${GlobalConfiguration().getValue('local_url')}AddtoCart/addOrdertoCart';
  final client = new http.Client();
  final response = await client.post(url,
      // body: json.encode(cart.toMap()),
      body: {
        'user_id': cart.userId,
        'pickup_point_id': cart.food.restaurant.id,
        'itemid': cart.food.id,
        'quantity': cart.quantity.toString()
      });
  if (response.statusCode == 200) {
   Cart.fromJSON(json.decode(response.body)['result']);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
  return Cart.fromJSON(json.decode(response.body)['result']);
}

Future<bool> updateCart(Cart cart) async {
  User _user = userRepo.currentUser.value;
  if (!_user.auth) {
    return false;
  }
  bool temp;
  cart.userId = _user.id;
  final String url =
      '${GlobalConfiguration().getValue('local_url')}AddtoCart/editQuantity';
  final client = new http.Client();
  final response = await client.post(
    url,
    body: {'id': cart.id, 'quantity': cart.quantity.toString()},
  );
  if (response.statusCode == 200) {
    temp = json.decode(response.body)['success'];
    
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    // return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
  return temp;
}

Future<bool> removeCart(Cart cart) async {
  User _user = userRepo.currentUser.value;
  if (!_user.auth) {
    return false;
  }
  // final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('local_url')}AddtoCart/removeOrderItem?addtocartid=${cart.id}';
  final client = new http.Client();
  final response = await client.get(url);
  return Helper.getBoolData(json.decode(response.body));
}

Future<bool> placeOrder(
    List placecart,
    String restaurantId,
    double totalAmmount,
    double couponAmmount,
    String couponCode,
    int totalDeliveryCharge,
    int appCharge,
    double tax) async {

      print('item_name'+placecart.toString());
  User _user = userRepo.currentUser.value;
  if (!_user.auth) {
    return false;
  }
  String couponAmt;
  String coupon;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('couponCode')) {
    couponAmt = '';
    coupon = '';
  } else {
    couponAmt = couponAmmount.toString();
    coupon = couponCode;
  }
  bool temp;

  String total = totalAmmount.toString();
  String address = _user.address;
  String latitude = _user.lat;
  String langitude = _user.lng;



  final String url =
      '${GlobalConfiguration().getValue('local_url')}Orders/createOrder';
  final client = new http.Client();
  final response = await client.post(url,
      // body: json.encode(cart.toMap()),
      body: {
        'app_user_id': _user.id,
        'pickup_point_id': restaurantId,
        'items': jsonEncode(placecart),
        'paymenttype': 'COD',
        'delivery_address': address,
        'delivery_lat': latitude,
        'delivery_lang': langitude,
        'total': total,
        'coupon': coupon,
        'couponprice': couponAmt,
        'shipping': totalDeliveryCharge.toString(),
        'app_charge': appCharge.toString(),
        'tax': tax.toString()
      });
 
  if (response.statusCode == 200) {
    temp = json.decode(response.body)['success'];
    return temp;
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
}
