

class VendorCategory {
  String id;
  String category;
  String catedes;
  String cateimg;
  String category_status;
  
  VendorCategory();

  VendorCategory.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'];
      category = jsonMap['categry'];
      catedes = jsonMap['catedes'];
      cateimg = jsonMap['cateimg'];
      category_status = jsonMap['category_status'];
    
    } catch (e) {
       id = '';
      category ='';
      catedes = '';
      cateimg = '';
      category_status = '';
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["categry"] = category;
    map["catedes"] = catedes;
    map["cateimg"] = cateimg;
    map["category_status"] = category_status;
    return map;
  }

}
