// To parse this JSON data, do
//
//     final empty = emptyFromJson(jsonString);

import 'dart:convert';

OpenCart emptyFromJson(String str) => OpenCart.fromJson(json.decode(str));

String emptyToJson(OpenCart data) => json.encode(data.toJson());

class OpenCart {
    OpenCart({
        this.name,
        this.quantity,
    });

    String name;
    String quantity;

    factory OpenCart.fromJson(Map<String, dynamic> json) => OpenCart(
        name: json["itemsname"],
        quantity: json["itemsquantity"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "quantity": quantity,
    };
}
