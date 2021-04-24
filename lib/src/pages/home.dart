import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/models/user.dart';
import 'package:food_delivery_app/src/pages/category_list.dart';
import 'package:food_delivery_app/src/repository/restaurant_repository.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/CardsOfferWidget.dart';
import '../elements/DropDownBox.dart';
import '../elements/CaregoriesCarouselWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/FoodsCarouselWidget.dart';
import '../elements/GridWidget.dart';
import '../elements/HomeSliderWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  HomeWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;
  var _currentCity;
  List list = List();

  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
  }

  String resultCodeC;
  String resultMessageC;
  String statusC;
  bool statusApiC;
  bool isLoading = true;
  bool _selected = false;
  int limit;
  var address = "Current Location";
  User user;

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List _cities = [
    "Cluj-Napoca",
    "Bucuresti",
    "Timisoara",
    "Brasov",
    "Constanta"
  ];

  List<Restaurant> topRestaurants = <Restaurant>[];
  Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _currentLocation();
    getDistanceLimit();
    _dropDownMenuItems = getDropDownMenuItems();
    _currentCity = _dropDownMenuItems[0].value;
    // _getCategory();
    // const fiveSeconds = const Duration(seconds: 1);
    // Timer.periodic(fiveSeconds, (Timer t) =>  HomeController());
  }

  _currentLocation() async {
    await getLocationForCurrent();
  }

  Future<void> getDistanceLimit() async {
    Map data;
    var client = http.Client();
    try {
      String url = Strings.baseUrl + 'Dashboard/loadCustomerRange';
      var response = await client.get(url);
      data = json.decode(response.body);
      if (data["resultcode"] == "200") {
        setState(() {
          limit = int.parse(data["result"]["typevalue"]);
        });
      }
    } catch (Exception) {
      print(Exception);
    }
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String city in _cities) {
      items.add(new DropdownMenuItem(value: city, child: new Text(city)));
    }
    return items;
  }

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _currentCity = selectedCity;
    });
  }

  Future<void> listenForTopRestaurants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('category', _currentCity);
    prefs.getString('category');
    final Stream<Restaurant> stream =
        await getNearRestaurants(prefs.getString('category'));
    stream.listen((Restaurant _restaurant) {
      setState(() => topRestaurants.add(_restaurant));
    }, onError: (a) {}, onDone: () {});
    // _con.refreshHome();
  }

  _getCategory() async {
    var client = http.Client();
    try {
      String url = Strings.baseUrl + 'Category/getCategory';
      var response = await client.get(url);
      if (response.statusCode == 200) {
        Map data;
        data = jsonDecode(response.body);
        // print(data);
        resultCodeC = data["resultcode"];
        statusApiC = data["success"];
        resultMessageC = data["resultmessage"];
        if (statusApiC) {
          setState(() {
            list = data["result"];
            // print(list);
            if (list.length != 0) {
              isLoading = false;
              _currentCity = list[0]["categry"];
              // print(_currentCity);
            }
          });
          Fluttertoast.showToast(
              msg: resultMessageC,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          Fluttertoast.showToast(
              msg: resultMessageC,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } catch (Exception) {
      print(Exception);
    }
  }

  getLocationForCurrent() async {
    await Geolocator.getCurrentPosition()
        .then((Position position) => {_currentPosition = position});

    // From coordinates
    final coordinates =
        new Coordinates(_currentPosition.latitude, _currentPosition.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print("${first.featureName} : ${first.addressLine}");
    setState(() {
      address = first.addressLine;
      currentUser.value.lat = _currentPosition.latitude.toString();
      currentUser.value.lng = _currentPosition.longitude.toString();
    });
  }

  _storeLatLng(double lat, double lng) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setDouble("deliverylat", lat);
      prefs.setDouble("deliverylng", lng);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return Text(
              S.of(context).home,
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .merge(TextStyle(letterSpacing: 1)),
            );
          },
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshHome,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: List.generate(
                settingsRepo.setting.value.homeSections.length, (index) {
              String _homeSection =
                  settingsRepo.setting.value.homeSections.elementAt(index);
              switch (_homeSection) {
                case 'slider':
                  return HomeSliderWidget(slides: _con.slides);
                case 'search':
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SearchBarWidget(
                          onClickFilter: (event) {
                            widget.parentScaffoldKey.currentState
                                .openEndDrawer();
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Delivery To",
                            style: Theme.of(context).textTheme.headline4,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Icon(Icons.location_on_outlined,
                                  color: Colors.grey.shade600),
                              flex: 0,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlacePicker(
                                        apiKey:
                                            'AIzaSyB38zgsBuf31H8icWOX5sKQGXXb84JnDhE',
                                        // Put YOUR OWN KEY here.
                                        onPlacePicked: (result) {
                                          print(result);
                                          setState(() {
                                            this.address =
                                                result.formattedAddress;
                                            currentUser.value.lat = result
                                                .geometry.location.lat
                                                .toString();
                                            currentUser.value.address =
                                                result.formattedAddress;
                                            currentUser.value.lng = result
                                                .geometry.location.lng
                                                .toString();
                                            _storeLatLng(
                                                result.geometry.location.lat,
                                                result.geometry.location.lng);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        initialPosition:
                                            LatLng(-33.8567844, 151.213108),
                                        useCurrentLocation: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                    margin: EdgeInsets.only(left: 10.0),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Text(
                                        '$address',
                                        maxLines: 1,
                                        style: GoogleFonts.openSans(
                                          fontSize: 14,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    )),
                              ),
                              flex: 1,
                            )
                          ],
                        ),
                      )
                    ],
                  );

                case 'top_restaurants_heading':
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 15, left: 20, right: 20, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                S.of(context).top_restaurants,
                                style: Theme.of(context).textTheme.headline4,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                        if (settingsRepo.deliveryAddress.value?.address != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              S.of(context).near_to +
                                  " " +
                                  (settingsRepo.deliveryAddress.value?.address),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                      ],
                    ),
                  );
                case 'top_restaurants':
                  return CardsCarouselWidget(
                      restaurantsList: _con.topRestaurants,
                      heroTag: 'home_top_restaurants');
                
                  case 'trending_week_heading':
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 15, left: 20, right: 20, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Offers',
                                style: Theme.of(context).textTheme.headline4,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                        if (settingsRepo.deliveryAddress.value?.address != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              S.of(context).near_to +
                                  " " +
                                  (settingsRepo.deliveryAddress.value?.address),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                      ],
                    ),
                  );
                case 'trending_week':
                  return CardsOfferWidget(
                      offerList: _con.offers,
                      heroTag: 'home_top_restaurants');
                default:
                  return SizedBox(height: 0);
              }
            }),
          ),
        ),
      ),
    );
  }
}
