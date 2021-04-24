import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/food.dart';

class PlaceCart {
  String itemname;
  String itemquantity;
  String itemprice;

  PlaceCart({this.itemname,this.itemquantity,this.itemprice});
  
 PlaceCart.fromJson(Map<String, dynamic> json) {
  itemname = json['itemname'];
  itemquantity = json['itemquantity'];
  itemprice = json['itemprice'];
}


  Map toMap() {
    var map = new Map<String, dynamic>();
    map["itemname"] = itemname;
    map["itemname"] = itemname;
    map["itemprice"] = itemprice;

    return map;
  }


}
