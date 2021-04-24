class CouponModel {
   String id;
  String rate;
  String type;
  String couponcode;
  bool valid;

  CouponModel({this.rate, this.id, this.type,this.valid,this.couponcode});

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      rate: json['rate'],
      id: json['id'],
      type: json['type'],
      valid:json['success'],
      couponcode:json['couponcode']
    );
  }

}
