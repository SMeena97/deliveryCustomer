import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/pages/home.dart';
import 'package:food_delivery_app/src/repository/restaurant_repository.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FoodCategories extends StatefulWidget {
  @override
  _FoodCategoriesState createState() => _FoodCategoriesState();
}

class _FoodCategoriesState extends State<FoodCategories> {
  bool status = false;
  bool isLoading = true;
  String category;
  String resultCode;
  String resultMessage;
  bool statusApi;
  List list;
  bool isLoadingProgress = false;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  Position _currentPosition;

  _getCategories() async {
    setState(() {
      isLoadingProgress = true;
    });
    var client = http.Client();
    try {
      String url = Strings.baseUrl + 'Category/getCategory';
      var response = await client.get(url);
      print('url' + url);
      if (response.statusCode == 200) {
        Map data;
        data = jsonDecode(response.body);
        print("res" + data.toString());
        resultCode = data["resultcode"];
        statusApi = data["success"];
        resultMessage = data["resultmessage"];
        if (statusApi) {
          list = data["result"];
          print(list);
          setState(() {
            if (list.length != 0) {
              isLoading = false;
            }
          });
          setState(() {
            isLoadingProgress = false;
          });
        } else {
          setState(() {
            isLoadingProgress = false;
          });
          Fluttertoast.showToast(
              msg: resultMessage,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } catch (Exception) {
      setState(() {
        isLoadingProgress = false;
      });
      print(Exception);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _getCategories();
    });
    getLocation();
  }

  getLocation() async {
    await Geolocator.getCurrentPosition()
        .then((Position position) => {_currentPosition = position});

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("deliverylat", _currentPosition.latitude);
    prefs.setDouble("deliverylng", _currentPosition.longitude);

    currentUser.value.lat = _currentPosition.latitude.toString();
    currentUser.value.lng = _currentPosition.longitude.toString();
  }

  Future<void> listenForTopRestaurants(
      String id, GlobalKey<ScaffoldState> scaffoldKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('category', id);
    prefs.getString('category');
    await getNearRestaurants(prefs.getString('category'));
    Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        // ignore: missing_return
        Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          title: Container(
            child: new Text('Select Category',
                style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ))),
          ),
        ),
        body: isLoadingProgress
            ? Container(
                color: Colors.transparent,
                child: Center(child: CircularProgressIndicator()),
              )
            : isLoading
                ? Center(
                    child: Text("No data"),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      child: Center(
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              child: GridView.count(
                                childAspectRatio: 2 / 2,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                crossAxisCount: 2,
                                children: List.generate(
                                    isLoading ? 0 : list.length, (index) {
                                  return Container(
                                    child: GestureDetector(
                                      onTap: () {
                                        /*print(list[index]["id"]);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FoodCategoriesList(
                                              list[index]["id"])));*/
                                        listenForTopRestaurants(
                                            list[index]["id"], scaffoldKey);
                                      },
                                      child: Card(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 25, horizontal: 25),
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15.0),
                                                topRight:
                                                    Radius.circular(15.0)),
                                          ),
                                          child: getWiget(index)),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  getWiget(int index) {
    return Container(
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          Container(
            child: !isLoading
                ? Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0)),
                        image: DecorationImage(
                            image: NetworkImage(list[index]["cateimg"]),
                            fit: BoxFit.cover)),
                  )
                : Container(
                    child: SvgPicture.asset('assets/svg/boxlogo.svg'),
                  ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(isLoading ? 'Categories' : list[index]["categry"],
                    style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ))),
                SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
