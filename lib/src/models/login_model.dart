// To parse this JSON data, do
//
//     final empty = emptyFromJson(jsonString);

import 'dart:convert';

LoginModel emptyFromJson(String str) => LoginModel.fromJson(json.decode(str));

String emptyToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
    LoginModel({
        this.resultcode,
        this.success,
        this.resultmessage,
        this.result,
    });

    String resultcode;
    String success;
    String resultmessage;
    Result result;

    factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        resultcode: json["resultcode"],
        success: json["success"],
        resultmessage: json["resultmessage"],
        result: Result.fromJson(json["result"]),
    );

    Map<String, dynamic> toJson() => {
        "resultcode": resultcode,
        "success": success,
        "resultmessage": resultmessage,
        "result": result.toJson(),
    };
}

class Result {
    Result({
        this.appUserId,
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
        this.auth,
    });

    String appUserId;
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
    bool auth;

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        appUserId: json["app_user_id"],
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
        auth: json["auth"],
    );

    Map<String, dynamic> toJson() => {
        "app_user_id": appUserId,
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
        "auth": auth,
    };
}
