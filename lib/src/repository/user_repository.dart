import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/credit_card.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

ValueNotifier<User> currentUser = new ValueNotifier(User());

Future<User> login(User user) async {
  print(user.email);
  print(user.password);
  Map data;
  final String url =
      '${GlobalConfiguration().getValue('local_url')}AppUserProfile/loginAppUser?app_user_name=${user.email}&app_user_password=${user.password}';
  print(url);
  final client = new http.Client();
  final response = await client.get(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  data = json.decode(response.body);
  print("loginres" + data.toString());
  if (data["resultcode"] == "200") {
    setCurrentUser(response.body);
    currentUser.value = User.fromJSON(json.decode(response.body)['result']);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("id", currentUser.value.id);
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
  return currentUser.value;
}

Future<User> register(User user) async {
  print(user.name);
  print(user.email);
  print(user.password);
  print(user.alternatePhone);
  final String url =
      '${GlobalConfiguration().getValue('local_url')}AppUserProfile/addAppUser';
  Map data;
  final client = new http.Client();
  final response = await client.post(
    url,
    body: {
      'name': user.fullName,
      'app_user_name': user.name,
      'app_user_email': user.email,
      'app_user_password': user.password,
      'app_user_contact': user.phone,
      'alternate_contact': user.alternatePhone
    },
  );
  print('register res');
  print(response.body);
  data = json.decode(response.body);
  if (data["resultcode"] == "200") {
    setCurrentUser(response.body);
    currentUser.value = User.fromJSON(json.decode(response.body)['result']);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("id", currentUser.value.id);
    FirebaseFirestore.instance
        .collection("users")
        .doc("customer" + currentUser.value.id)
        .set({
      'nickname': currentUser.value.name,
      'id': "customer" + currentUser.value.id,
      'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'chattingWith': null
    });
  } else {
    Fluttertoast.showToast(
        msg: data["resultmessage"],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[200],
        textColor: Colors.black,
        fontSize: 16.0);
  }

  return currentUser.value;
}

Future<bool> resetPassword(User user) async {
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}send_reset_link_email';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    print(CustomTrace(StackTrace.current, message: response.body).toString());
    throw new Exception(response.body);
  }
}

Future<void> logout() async {
  currentUser.value = new User();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('current_user');
  prefs?.clear();
  currentUser.value.auth = false;
  // await getLocation();
}


void setCurrentUser(jsonString) async {
  try {
    if (json.decode(jsonString)['result'] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currentUser.value.auth = true;
      await prefs.setString(
          'current_user', json.encode(json.decode(jsonString)['result']));
      print("current user...");
      print(prefs.getString('current_user'));
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: jsonString).toString());
    throw new Exception(e);
  }
}

Future<void> setCreditCard(CreditCard creditCard) async {
  if (creditCard != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('credit_card', json.encode(creditCard.toMap()));
  }
}

// Future<User> getCurrentUser() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   //prefs.clear();
//   if (currentUser.value.auth == null && prefs.containsKey('current_user')) {
//     // if ( prefs.containsKey('current_user')) {
//     currentUser.value = User.fromJSON(json.decode(await prefs.get('current_user')));
//     currentUser.value.auth = true;
//   } else {
//     currentUser.value.auth = false;
//   }
//   // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
//   currentUser.notifyListeners();

//   return currentUser.value;
// }
Future<User> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
  if (prefs.containsKey('current_user')) {
    // if ( prefs.containsKey('current_user')) {
    currentUser.value =
        User.fromJSON(json.decode(await prefs.get('current_user')));
    print('current user...');
    print(currentUser.value);
    currentUser.value.auth = true;
    print('auth check..');
    print(currentUser.value);
  } else {
    currentUser.value.auth = false;
  }
  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  currentUser.notifyListeners();

  return currentUser.value;
}

Future<CreditCard> getCreditCard() async {
  CreditCard _creditCard = new CreditCard();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('credit_card')) {
    _creditCard =
        CreditCard.fromJSON(json.decode(await prefs.get('credit_card')));
  }
  return _creditCard;
}

Future<User> update(User user) async {
  // final String _apiToken = 'api_token=${currentUser.value.apiToken}';
  // final String url = '${GlobalConfiguration().getValue('api_base_url')}users/${currentUser.value.id}?$_apiToken';

  final String url =
      '${GlobalConfiguration().getValue('local_url')}AppUserProfile/editAppUser';
  final client = new http.Client();
  final response = await client.post(
    url,
    body: {
      'app_user_id': user.id,
      'app_user_name': user.name,
      'app_user_address': user.address,
      'app_user_contact': user.phone,
      'app_user_email': user.email,
      'app_user_lat': user.lat,
      'app_user_lang': user.lng
    },
  );
  setCurrentUser(response.body);

  currentUser.value = User.fromJSON(json.decode(response.body)['result']);
  return currentUser.value;
}

Future<Stream<Address>> getAddresses() async {
  User _user = currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?$_apiToken&search=user_id:${_user.id}&searchFields=user_id:=&orderBy=updated_at&sortedBy=desc';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Address.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return new Stream.value(new Address.fromJSON({}));
  }
}

Future<Address> addAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?$_apiToken';
  final client = new http.Client();
  try {
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(address.toMap()),
    );
    return Address.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return new Address.fromJSON({});
  }
}

Future<Address> updateAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  address.userId = _user.id;
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = new http.Client();
  try {
    final response = await client.put(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(address.toMap()),
    );
    return Address.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return new Address.fromJSON({});
  }
}

Future<Address> removeDeliveryAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses/${address.id}?$_apiToken';
  final client = new http.Client();
  try {
    final response = await client.delete(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );
    return Address.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return new Address.fromJSON({});
  }
}
