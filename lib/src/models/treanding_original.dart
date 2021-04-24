// To parse this JSON data, do
//
//     final empty = emptyFromJson(jsonString);

import 'dart:convert';

Treanding emptyFromJson(String str) => Treanding.fromJson(json.decode(str));

String emptyToJson(Treanding data) => json.encode(data.toJson());

class Treanding {
    Treanding({
        this.resultcode,
        this.success,
        this.resultmessage,
        this.data,
    });

    String resultcode;
    String success;
    String resultmessage;
    List<Datum> data;

    factory Treanding.fromJson(Map<String, dynamic> json) => Treanding(
        resultcode: json["resultcode"],
        success: json["success"],
        resultmessage: json["resultmessage"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "resultcode": resultcode,
        "success": success,
        "resultmessage": resultmessage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        this.id,
        this.name,
        this.categoryId,
        this.description,
        this.price,
        this.mrp,
     
        this.restaurant,
    });

    String id;
    String name;
    String categoryId;
    String description;
    String price;
    String mrp;
  
    Restaurant restaurant;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
        categoryId: json["category_id"],
        description: json["description"],
        price: json["price"],
        mrp: json["mrp"],

        restaurant: Restaurant.fromJson(json["restaurant"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "category_id": categoryId,
        "description": description,
        "price": price,
        "mrp": mrp,

        "restaurant": restaurant.toJson(),
    };
}

class Restaurant {
    Restaurant({
        this.pickupPointId,
        this.pickupPointName,
        this.pickupPointAddress,
        this.pickupPointZip,
        this.pickupPointContact,

        this.userId,
        this.pickupPointDesc,
        this.pickupPointInfo,
        this.pickupPointStarttime,
        this.pickupPointClosetime,
    });

    String pickupPointId;
    String pickupPointName;
    String pickupPointAddress;
    String pickupPointZip;
    String pickupPointContact;

    String userId;
    dynamic pickupPointDesc;
    dynamic pickupPointInfo;
    String pickupPointStarttime;
    String pickupPointClosetime;

    factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        pickupPointId: json["pickup_point_id"],
        pickupPointName: json["pickup_point_name"],
        pickupPointAddress: json["pickup_point_address"],
        pickupPointZip: json["pickup_point_zip"],
        pickupPointContact: json["pickup_point_contact"],

        userId: json["user_id"],
        pickupPointDesc: json["pickup_point_Desc"],
        pickupPointInfo: json["pickup_point_info"],
        pickupPointStarttime: json["pickup_point_starttime"],
        pickupPointClosetime: json["pickup_point_closetime"],
    );

    Map<String, dynamic> toJson() => {
        "pickup_point_id": pickupPointId,
        "pickup_point_name": pickupPointName,
        "pickup_point_address": pickupPointAddress,
        "pickup_point_zip": pickupPointZip,
        "pickup_point_contact": pickupPointContact,
        
        "user_id": userId,
        "pickup_point_Desc": pickupPointDesc,
        "pickup_point_info": pickupPointInfo,
        "pickup_point_starttime": pickupPointStarttime,
        "pickup_point_closetime": pickupPointClosetime,
    };
}
