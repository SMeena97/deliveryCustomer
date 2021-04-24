import '../helpers/custom_trace.dart';
import '../models/media.dart';

enum UserState { available, away, busy }

class User {
  String id;
  String fullName;
  String name;
  String email;
  String password;
  String apiToken;
  String deviceToken;
  String phone;
  String address;
  String bio;
  String image;
  String lat;
  String lng;
  String alternatePhone;

  // used for indicate if client logged in or not
  bool auth;

//  String role;

  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['app_user_id'].toString();
      name = jsonMap['app_user_name'] != null ? jsonMap['app_user_name'] : '';
      fullName = jsonMap['name'] !=null ? jsonMap['name']: '';
      lat = jsonMap['app_user_lat'] != null ? jsonMap['app_user_lat'] : '';
      lng = jsonMap['app_user_lang'] != null ? jsonMap['app_user_lang'] : '';
       address = jsonMap['app_user_address'] != null ? jsonMap['app_user_address'] : '';
      email = jsonMap['app_user_email'] != null ? jsonMap['app_user_email'] : '';
      apiToken = jsonMap['api_token'];
      deviceToken = jsonMap['device_token'];
      phone = jsonMap['app_user_contact'] != null ? jsonMap['app_user_contact'] : '';
      alternatePhone=jsonMap['alternate_contact'] != null ? jsonMap['alternate_contact'] : '';
      try {
        // address = jsonMap['custom_fields']['address']['view'];
      } catch (e) {
        address = "";
      }
      try {
        bio = jsonMap['custom_fields']['bio']['view'];
      } catch (e) {
        bio = "";
      }
      // image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["app_user_id"] = id;
    map['name']=fullName;
    map["app_user_email"] = email;
    map["app_user_name"] = name;
    map["app_user_password"] = password;
    map["api_token"] = apiToken;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["app_user_contact"] = phone;
    map["app_user_address"] = address;
    map["bio"] = bio;
    map["image"] = image;
    return map;
  }

  Map toRestrictMap() {
    var map = new Map<String, dynamic>();
    map["app_user_id"] = id;
    map["app_user_email"] = email;
    map["app_user_name"] = name;
   
    map["device_token"] = deviceToken;
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    return map.toString();
  }

  bool profileCompleted() {
    return address != null && address != '' && phone != null && phone != '';
  }
}
