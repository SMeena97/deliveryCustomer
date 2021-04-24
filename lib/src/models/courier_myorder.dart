// To parse this JSON data, do
//
//     final empty = emptyFromJson(jsonString);

import 'dart:convert';

CourierMyOrderModel emptyFromJson(String str) => CourierMyOrderModel.fromJson(json.decode(str));

String emptyToJson(CourierMyOrderModel data) => json.encode(data.toJson());

class CourierMyOrderModel {
    CourierMyOrderModel({
        this.resultcode,
        this.success,
        this.resultmessage,
        this.result,
    });

    String resultcode;
    bool success;
    String resultmessage;
    List<Result> result;

    factory CourierMyOrderModel.fromJson(Map<String, dynamic> json) => CourierMyOrderModel(
        resultcode: json["resultcode"],
        success: json["success"],
        resultmessage: json["resultmessage"],
        result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "resultcode": resultcode,
        "success": success,
        "resultmessage": resultmessage,
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
    };
}

class Result {
    Result({
        this.courierid,
        this.goodsName,
        this.goodsWeight,
        this.status,
        this.quantityType,
        this.quantity,
        this.amount,
        this.total,
        this.shipping,
        this.paymenttype,
        this.payid,
        this.coupon,
        this.couponprice,
        this.pickupAddress,
        this.pickupLat,
        this.pickupLng,
        this.couriertime,
        this.pickuptime,
        this.deliveryAddress,
        this.deliveryLat,
        this.deliveryLang,
        this.images,
        this.billImage,
        this.appUserId,
        this.deliveryboyid,
        this.appUserName,
        this.appUserAddress,
        this.appUserZip,
        this.appUserContact,
        this.appUserLat,
        this.appUserLang,
        this.appUserStatus,
        this.image,
        this.appUserEmail,
        this.appUserPassword,
        this.id,
        this.deliveryboyCode,
        this.dname,
        this.dmobile,
        this.dusername,
        this.dpassword,
        this.deliveryBoyStatus,
        this.daddress,
        this.delBoyLat,
        this.delBoyLng,
    });

    String courierid;
    String goodsName;
    String goodsWeight;
    String status;
    String quantityType;
    String quantity;
    String amount;
    String total;
    String shipping;
    String paymenttype;
    String payid;
    String coupon;
    String couponprice;
    String pickupAddress;
    String pickupLat;
    String pickupLng;
    String couriertime;
    DateTime pickuptime;
    String deliveryAddress;
    String deliveryLat;
    String deliveryLang;
    String images;
    String billImage;
    String appUserId;
    String deliveryboyid;
    String appUserName;
    String appUserAddress;
    String appUserZip;
    String appUserContact;
    String appUserLat;
    String appUserLang;
    String appUserStatus;
    String image;
    String appUserEmail;
    String appUserPassword;
    String id;
    dynamic deliveryboyCode;
    String dname;
    String dmobile;
    String dusername;
    String dpassword;
    String deliveryBoyStatus;
    String daddress;
    String delBoyLat;
    String delBoyLng;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        courierid: json["courierid"],
        goodsName: json["Goods_name"],
        goodsWeight: json["Goods_weight"],
        status: json["status"],
        quantityType: json["quantity_type"],
        quantity: json["quantity"],
        amount: json["amount"],
        total: json["total"],
        shipping: json["shipping"],
        paymenttype: json["paymenttype"],
        payid: json["payid"],
        coupon: json["coupon"],
        couponprice: json["couponprice"],
        pickupAddress: json["pickup_address"],
        pickupLat: json["pickup_lat"],
        pickupLng: json["pickup_lng"],
        couriertime:/* DateTime.parse(json["couriertime"])*/json["couriertime"],
        pickuptime: DateTime.parse(json["pickuptime"]),
        deliveryAddress: json["delivery_address"],
        deliveryLat: json["delivery_lat"],
        deliveryLang: json["delivery_lang"],
        images: json["images"],
        billImage: json["bill_image"],
        appUserId: json["app_user_id"],
        deliveryboyid: json["deliveryboyid"],
        appUserName: json["app_user_name"],
        appUserAddress: json["app_user_address"],
        appUserZip: json["app_user_zip"],
        appUserContact: json["app_user_contact"],
        appUserLat: json["app_user_lat"],
        appUserLang: json["app_user_lang"],
        appUserStatus: json["app_user_status"],
        image: json["image"],
        appUserEmail: json["app_user_email"],
        appUserPassword: json["app_user_password"],
        id: json["id"],
        deliveryboyCode: json["deliveryboy_code"],
        dname: json["dname"],
        dmobile: json["dmobile"],
        dusername: json["dusername"],
        dpassword: json["dpassword"],
        deliveryBoyStatus: json["delivery_boy_status"],
        daddress: json["daddress"],
        delBoyLat: json["del_boy_lat"],
        delBoyLng: json["del_boy_lng"],
    );

    Map<String, dynamic> toJson() => {
        "courierid": courierid,
        "Goods_name": goodsName,
        "Goods_weight": goodsWeight,
        "status": status,
        "quantity_type": quantityType,
        "quantity": quantity,
        "amount": amount,
        "total": total,
        "shipping": shipping,
        "paymenttype": paymenttype,
        "payid": payid,
        "coupon": coupon,
        "couponprice": couponprice,
        "pickup_address": pickupAddress,
        "pickup_lat": pickupLat,
        "pickup_lng": pickupLng,
        "couriertime": couriertime.toString()/*.toIso8601String()*/,
        "pickuptime": pickuptime.toIso8601String(),
        "delivery_address": deliveryAddress,
        "delivery_lat": deliveryLat,
        "delivery_lang": deliveryLang,
        "images": images,
        "bill_image": billImage,
        "app_user_id": appUserId,
        "deliveryboyid": deliveryboyid,
        "app_user_name": appUserName,
        "app_user_address": appUserAddress,
        "app_user_zip": appUserZip,
        "app_user_contact": appUserContact,
        "app_user_lat": appUserLat,
        "app_user_lang": appUserLang,
        "app_user_status": appUserStatus,
        "image": image,
        "app_user_email": appUserEmail,
        "app_user_password": appUserPassword,
        "id": id,
        "deliveryboy_code": deliveryboyCode,
        "dname": dname,
        "dmobile": dmobile,
        "dusername": dusername,
        "dpassword": dpassword,
        "delivery_boy_status": deliveryBoyStatus,
        "daddress": daddress,
        "del_boy_lat": delBoyLat,
        "del_boy_lng": delBoyLng,
    };
}
