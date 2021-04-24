import '../helpers/custom_trace.dart';

class SlideBanner {
  String id;
  String image;

  SlideBanner();

  SlideBanner.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'];
      image = jsonMap['bnimg'];
      
    } catch (e) {
      id = '';
      image = '';
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["bnimg"] = image;

    return map;
  }


}
