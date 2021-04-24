import 'package:flutter/material.dart';

import '../elements/CardsCarouselLoaderWidget.dart';
import '../models/restaurant.dart';
import '../models/vendor_category.dart';
import 'CardWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/home_controller.dart';
import '../repository/restaurant_repository.dart';

// ignore: must_be_immutable
class DropDownBox extends StatefulWidget {
  List<VendorCategory> categoryList;
  String heroTag;

  DropDownBox({Key key, this.categoryList, this.heroTag}) : super(key: key);

  @override
  _DropDownBoxState createState() => _DropDownBoxState();
}

class _DropDownBoxState extends State<DropDownBox> {
  List<Restaurant> topRestaurants = <Restaurant>[];

  @override
  void initState() {
    super.initState();
  }

  Future<void> listenForTopRestaurants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getString('category');
    final Stream<Restaurant> stream =
        await getNearRestaurants(prefs.getString('category'));
    stream.listen((Restaurant _restaurant) {
      setState(() => topRestaurants.add(_restaurant));
    }, onError: (a) {}, onDone: () {});
  }

  VendorCategory dropdownValue;

  @override
  Widget build(BuildContext context) {

    //   dropdownValue.fromJSON(Map<String, dynamic> jsonMap) {
    //   id: "16"; categry: "restuarants and kitchens "; catedes: "food and meals"; cateimg: "https://marketing.rexxtechnologies.com/delivery-app/admin/itemimg/5e.jpg"; category_status: "active";
    // };

    print("dropdownValue"+dropdownValue.toString());
    return DropdownButton<VendorCategory>(
      isDense: false,
      isExpanded: true,
      value: dropdownValue,
      /*  icon: Icon(Icons.arrow_downward),
                          iconSize: 24,
                          elevation: 16,*/
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (VendorCategory newValue) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('category', newValue.id);
        listenForTopRestaurants();
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: widget.categoryList.map<DropdownMenuItem<VendorCategory>>((value) {
        // print('fr'+value.toMap().toString());
        return DropdownMenuItem<VendorCategory>(
          value: value,
          child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(value.category)),
        );
      }).toList(),
      // hint: Text("Select Categories"),
    );
  }
}
