// To parse this JSON data, do
//
//     final empty = emptyFromJson(jsonString);

import 'dart:convert';

Empty emptyFromJson(String str) => Empty.fromJson(json.decode(str));

String emptyToJson(Empty data) => json.encode(data.toJson());

class Empty {
    Empty({
        this.data,
        this.message,
        this.status,
    });

    String data;
    String message;
    int status;

    factory Empty.fromJson(Map<String, dynamic> json) => Empty(
        data: json["data"],
        message: json["message"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "data": data,
        "message": message,
        "status": status,
    };
}
