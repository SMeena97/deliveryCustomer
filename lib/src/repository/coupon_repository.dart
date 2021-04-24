import 'dart:convert';

import 'package:food_delivery_app/src/models/coupon_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/coupon.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;
import 'package:global_configuration/global_configuration.dart';

// Future<Stream<Coupon>> verifyCoupon(String code) async {
//    User _user = userRepo.currentUser.value;
//   String url = '${GlobalConfiguration().getValue('local_url')}Coupon/validateCouponCode?user_id=${_user.id}&couponcode=$code';
 
//   if (!_user.auth) {
//     return new Stream.value(null);
//   }
//   // Map<String, dynamic> query = {
//   //   'api_token': _user.apiToken,
//   //   'with': 'discountables',
//   //   'search': 'code:$code',
//   //   'searchFields': 'code:=',
//   // };
//   // uri = uri.replace(queryParameters: query);
//   // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
//   try {
//     final client = new http.Client();
//     final streamedRest = await client.send(http.Request('get',  Uri.parse(url)));
//     return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
//     return Coupon.fromJSON(data);
//     });
//   } catch (e) {
//     // print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
//     return new Stream.value(new Coupon.fromJSON({}));
//   }
// }

Future<CouponModel> verifyCoupon(String code,String id) async {
  Map data;
   User _user = userRepo.currentUser.value;
  String url = '${GlobalConfiguration().getValue('local_url')}Coupon/validateCouponCode?user_id=${_user.id}&couponcode=$code&vendor_id=$id';
   final response = await http.get(url);
   data=jsonDecode(response.body);
   try{
  if (data["resultcode"]=="200") {
    return CouponModel.fromJson(jsonDecode(response.body));
  }} catch(e) {
    print('error in validateCouponCode');
    print(e);
  }
 return CouponModel.fromJson(jsonDecode(response.body));
}

Future<Coupon> saveCoupon(Coupon coupon) async {
  if (coupon != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('coupon', json.encode(coupon.toMap()));
  }
  return coupon;
}

Future<Coupon> getCoupon() async {
  Coupon _coupon = Coupon.fromJSON({});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('coupon')) {
    _coupon = Coupon.fromJSON(json.decode(await prefs.get('coupon')));
  }
  return _coupon;
}
