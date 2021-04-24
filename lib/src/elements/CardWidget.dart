import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import 'package:geolocator/geolocator.dart';

// ignore: must_be_immutable
class CardWidget extends StatelessWidget {
  Restaurant restaurant;
  String heroTag;

  CardWidget({Key key, this.restaurant, this.heroTag}) : super(key: key);


    Future<double> calculateDistance(lat2, lon2)async {   
     SharedPreferences prefs = await SharedPreferences.getInstance(); 
    double distanceInMeters =Geolocator.distanceBetween(prefs.getDouble("deliverylat"), prefs.getDouble("deliverylng"), lat2, lon2);
    double km=distanceInMeters/1000;
     
      return km;
  
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,
      margin: EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 15, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Image of the card
          Stack(
            fit: StackFit.loose,
            alignment: AlignmentDirectional.bottomStart,
            children: <Widget>[
              Hero(
                tag: this.heroTag + restaurant.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                  child: CachedNetworkImage(
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    imageUrl: restaurant.image,
                    placeholder: (context, url) => Image.asset(
                      'assets/img/loading.gif',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        restaurant.name,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      Text(
                        Helper.skipHtml(restaurant.description),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: Theme.of(context).textTheme.caption,
                      ),
                      SizedBox(height: 5),
                      // Row(
                      //   children: Helper.getStarsList(double.parse(restaurant.rate)),
                      // ),
                    ],
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      FlatButton(
                        padding: EdgeInsets.all(0),
                        onPressed: () {
                          // Navigator.of(context).pushNamed('/Pages', arguments: new RouteArgument(id: '1', param: restaurant));
                        },
                        child: Icon(Icons.directions, color: Theme.of(context).primaryColor),
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                      ),
                                                              
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
