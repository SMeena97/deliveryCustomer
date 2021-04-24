import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/offer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import 'package:geolocator/geolocator.dart';

// ignore: must_be_immutable
class CardOfferWidget extends StatelessWidget {
  Offer promo;
  String heroTag;

  CardOfferWidget({Key key, this.promo, this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:EdgeInsets.symmetric(horizontal:10),
      width: MediaQuery.of(context).size.width * 0.70,
      child: Card(       
          child: Row(
        children: [
          Container(
              width: 100, child: Image.network(promo.image, fit: BoxFit.cover)),
          Container(
              width: 140,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(promo.pickup_point_name,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(promo.rate + ' Off',
                        style: TextStyle(fontSize: 20,)),
                  ),
                  Text('USE CODE', style: TextStyle(fontSize: 16)),
                  Container(
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue)),
                      child: Text(promo.couponcode,
                          style: TextStyle(fontSize: 20))),
                ],
              ))
        ],
      )),
    );
  }
}
