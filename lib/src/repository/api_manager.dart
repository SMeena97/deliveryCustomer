import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/elements/courier_myorder.dart';
import 'package:food_delivery_app/src/models/courier_myorder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/treanding_original.dart';
import 'package:shared_preferences/shared_preferences.dart';

class API_Manager {

  // Future<Treanding> getTreadingFood() async {
  //   var client = http.Client();
  //   var celebritiesModel;
  //   try {
  //     var response = await client.get('https://multi-restaurants.smartersvision.com/api/foods?trending=week?limit=6');
    
  //     if (response.statusCode == 200) {
         
  //       var jsonString = response.body;
  //       var jsonMap = json.decode(jsonString);
    
  //       celebritiesModel = Treanding.fromJson(jsonMap);
  //     }
  //   } catch (Exception) {
  //     print('multi-restaurant exception');
  //     print(Exception);
  //     return celebritiesModel;
  //   }
     
  //   return celebritiesModel;
  // }
    Future<CourierMyOrderModel> getCourierMyorder() async {
    var client = http.Client();
    var celebritiesModel;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId=prefs.getString('id');
    try {
      var response = await client.get(Strings.baseUrl+'Courrier/loadCourrier?app_user_id=$userId');
    
      if (response.statusCode == 200) {      
        var jsonString = response.body;
        var jsonMap = json.decode(jsonString);
        celebritiesModel = CourierMyOrderModel.fromJson(jsonMap);
      }
    } catch (Exception) {
      
      print(Exception);
      return celebritiesModel;
    }
     
    return celebritiesModel;
  }

   Future<String> getGoogleMapApiKey() async {
    var client = http.Client();
    var mapKey;
    Map data;
    try {
      var response = await client.get(Strings.baseUrl+'Dashboard/loadMapKey');
      data=json.decode(response.body);
      if (data["resultcode"]=="200") {        
        mapKey = data["result"]["map_api_key"];
        return mapKey;
      }
    } catch (Exception) {
      print(Exception);
     
    }
     
    return mapKey;
  }
}