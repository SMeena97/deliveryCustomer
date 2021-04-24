import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../elements/CardsCarouselLoaderWidget.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import 'CardWidget.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class CardsCarouselWidget extends StatefulWidget {
  List<Restaurant> restaurantsList;
  String heroTag;

  CardsCarouselWidget({Key key, this.restaurantsList, this.heroTag})
      : super(key: key);

  @override
  _CardsCarouselWidgetState createState() => _CardsCarouselWidgetState();
}

class _CardsCarouselWidgetState extends State<CardsCarouselWidget> {
  final Geolocator _geolocator = Geolocator();
  Position _currentPosition;
  LocationData _locationData;
  Restaurant restaurant;
  int limit;
  double userLimit;
  double lat = 0.0;
  double lng = 0.0;
  double distance2;
  dynamic currentLat2;
  dynamic currentLng2;
  int count = 0;

  callService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('deliverylat')) {
      await getLocation();
    } else {
      if(mounted){
        setState(() {
          lat = prefs.getDouble("deliverylat");
          lng = prefs.getDouble("deliverylng");
        });
      }
     /* lat = prefs.getDouble("deliverylat");
      lng = prefs.getDouble("deliverylng");*/
    }
    await getDistanceLimit();
  }




  @override
  void initState() {
    super.initState();
    // callService();
    const fiveSeconds = const Duration(seconds: 1);
    if (mounted) Timer.periodic(fiveSeconds, (Timer t) => callService());
    // callService();
  }

  Future<void> getDistanceLimit() async {
    Map data;
    var client = http.Client();
    try {
      String url = Strings.baseUrl + 'Dashboard/loadDeliveryRange';
      var response = await client.get(url);
      data = json.decode(response.body);
      if (data["resultcode"] == "200") {
        setState(() {
          limit = int.parse(data["result"]["typevalue"]);
          distance2 = calculateDistance(
              currentLat2,
              currentLng2,
              double.parse(restaurant.latitude),
              double.parse(restaurant.longitude));
        });
      }
    } catch (Exception) {
      print(Exception);
    }
  }

  getLocation() async {
    await Geolocator.getCurrentPosition()
        .then((Position position) => {_currentPosition = position});

    setState(() {
      print(lat + lng);
      lat = _currentPosition.latitude;
      lng = _currentPosition.latitude;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("deliverylat", _currentPosition.latitude);
    prefs.setDouble("deliverylng", _currentPosition.longitude);
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return (12742 * asin(sqrt(a))).roundToDouble();
  }

  @override
  Widget build(BuildContext context) {
    return limit == null
        ? CardsCarouselLoaderWidget()
        : !widget.restaurantsList.isEmpty
            ? Container(
                height: 288,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.restaurantsList.length,
                  itemBuilder: (context, index) {
                    double lat2 = double.parse(
                        widget.restaurantsList[index].latitude != ""
                            ? widget.restaurantsList[index].latitude
                            : '0.0');
                    double lng2 = double.parse(
                        widget.restaurantsList[index].longitude != ""
                            ? widget.restaurantsList[index].longitude
                            : '0.0');
                    userLimit = calculateDistance(lat, lng, lat2, lng2);
                    if (userLimit.round() <= limit) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed('/Details',
                              arguments: RouteArgument(
                                id: '0',
                                param:
                                    widget.restaurantsList.elementAt(index).id,
                                heroTag: widget.heroTag,
                              ));
                        },
                        child: CardWidget(
                            restaurant: widget.restaurantsList.elementAt(index),
                            heroTag: widget.heroTag),
                      );
                    } else {
                      return Container();
                    }

                  },
                ),
              )
            : Center(
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: Text('No shops available in your area')));
    ;
  }
}
