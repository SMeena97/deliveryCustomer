// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

MyOrder welcomeFromJson(String str) => MyOrder.fromJson(json.decode(str));

String welcomeToJson(MyOrder data) => json.encode(data.toJson());

class MyOrder {
  MyOrder({
    this.resultcode,
    this.success,
    this.resultmessage,
    this.result,
  });

  String resultcode;
  bool success;
  String resultmessage;
  List<Result> result;

  factory MyOrder.fromJson(Map<String, dynamic> json) => MyOrder(
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };

  static Future<Stream<MyOrder>> fromJSON(data) {}
}

class Result {
  Result(
      {this.orderid,
      this.status,
      this.total,
      this.paymenttype,
      this.shipping,
      this.ordertime,
      this.deliverboyid,
      this.appcharge,
      this.dmobile});

  String orderid;
  String status;
  String total;
  String shipping;
  String paymenttype;
  String ordertime;
  String deliverboyid;
  String appcharge;
  String dmobile;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        orderid: json["orderid"],
        status: json["status"],
        total: json["total"],
        shipping: json["shipping"],
        paymenttype: json["paymenttype"],
        ordertime: json["ordertime"],
        deliverboyid: json["deliveryboyid"],
        appcharge: json["app_charge"],
        dmobile: json["dmobile"],
      );

  Map<String, dynamic> toJson() => {
        "orderid": orderid,
        "status": status,
        "total": total,
        "paymenttype": paymenttype,
        "ordertime": ordertime,
        "deliveryboyid": deliverboyid,
        "shipping": shipping,
        "appcharge": appcharge,
        "dmobile": dmobile,
      };
}
