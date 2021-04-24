import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/elements/CardOfferWidget.dart';
import 'package:food_delivery_app/src/models/offer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../elements/CardsCarouselLoaderWidget.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import 'CardWidget.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class CardsOfferWidget extends StatefulWidget {
  List<Offer> offerList;
  String heroTag;

  CardsOfferWidget({Key key, this.offerList, this.heroTag})
      : super(key: key);

  @override
  _CardsOfferWidgetState createState() => _CardsOfferWidgetState();
}

class _CardsOfferWidgetState extends State<CardsOfferWidget> {


  @override
  void initState() {
    super.initState();     
  }


  @override
  Widget build(BuildContext context) {
    return widget.offerList.isEmpty
        ? CardsCarouselLoaderWidget()
        : Container(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.offerList.length,
                  itemBuilder: (context, index) {                                                                    
                      return CardOfferWidget(
                            promo: widget.offerList.elementAt(index),
                            heroTag: widget.heroTag);                                        
                  },
                ),
              );       
    
  }
}
