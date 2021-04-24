class Offer {
  String id;
  String couponcode;
  String rate;
  String type;
  String coupon_usage;
  String coupon_status;
  String pickup_point_name;
  String image;

  Offer();

  Offer.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'];
      couponcode = jsonMap['couponcode'];
      rate = jsonMap['rate'];
      type = jsonMap['type'];
      coupon_usage = jsonMap['coupon_usage'];
      coupon_status = jsonMap['coupon_status'];
      pickup_point_name = jsonMap['pickup_point_name'];
      image = jsonMap['image'];
   
    } catch (e) {
      id = '';
      couponcode = '';
      rate = '0';
      type = '';
      coupon_usage = '0';
      coupon_status = '';
      pickup_point_name = '';
      image = '';
   
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'couponcode': couponcode,
      'rate': rate,
      'type': type,
      'coupon_usage': coupon_usage,
      'coupon_status': coupon_status,
      'pickup_point_name':pickup_point_name,
      'image':image
    };
  }
}
