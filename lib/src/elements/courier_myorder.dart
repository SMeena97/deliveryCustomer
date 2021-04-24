import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/src/chat/chat.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/pages/courier_tracking.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:food_delivery_app/generated/l10n.dart';

class CourierMyOrder extends StatelessWidget {
  final String courierId;
  final String orderTime;
  final String orderStatus;
  final String deliveryboyid;
  final String destLat;
  final String destLng;
  final String mobile;
  final String time;

  CourierMyOrder(
      {this.courierId,
      this.orderTime,
      this.orderStatus,
      this.deliveryboyid,
      this.destLat,
      this.destLng,
      this.mobile,
      this.time});

  bool isLoading = true;

  final String mapimg = 'assets/images/pin.svg';
  final String chatimg = 'assets/images/chat.svg';

  Future<void> _showMyDialog(String orderId, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: Text("Do you want cancel Courier"),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                postCustomerCancel(orderId, context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
   /* var newDateTimeObj2 = new DateFormat("dd-MM-yyyy HH:mm:ss").parse(time);
    print("newDateTimeObj2"+newDateTimeObj2.toString());*/
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Card(
            elevation: 1,
            child: Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: new Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Align(
                                  child: Text(
                                    S.of(context).courier_id+':',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  alignment: Alignment.centerLeft,
                                ),
                                Text(
                                  courierId,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            flex: 1,
                          ),
                          Expanded(
                            child:
                                /*Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                children: [
                                  */ /*Text(
                                    'Order Status :',
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),*/ /*

                                ],
                              ),
                            ),*/
                                Align(
                              child: Text(
                                orderStatus,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: orderStatus == "Cancelled" ||
                                            orderStatus == "Delivered"
                                        ? Colors.red
                                        : Colors.green),
                              ),
                              alignment: Alignment.centerRight,
                            ),
                            flex: 1,
                          ),
                          // SizedBox(width: 20),
                        ],
                      )),
                  SizedBox(height: 8),
                  new Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              new Text(
                                'Date :',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              new Text(
                                DateFormat("dd-MM-yyyy")
                                    .format(DateTime.parse(orderTime)),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.black26),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10,right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              new Text(
                                'Time :',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              new Text(
                                time,
                                style: TextStyle(
                                    fontSize: 10, color: Colors.black26),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  orderStatus == 'Confirmed' || orderStatus == 'On Way'
                      ? Container(
                          padding: EdgeInsets.only(right: 20),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new RaisedButton(
                                  elevation: 0.0,
                                  shape: new RoundedRectangleBorder(
                                      borderRadius:
                                          new BorderRadius.circular(5.0)),
                                  padding: EdgeInsets.only(
                                      top: 1.0,
                                      bottom: 1.0,
                                      right: 3.0,
                                      left: 3.0),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Chat(
                                                  peerId: deliveryboyid,
                                                  orderId: courierId,
                                                )));
                                  },
                                  child: new Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      new SvgPicture.asset(
                                        'assets/images/chat.svg',
                                        height: 20.0,
                                        width: 20.0,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: new Text(
                                            "Chat",
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.bold),
                                          ))
                                    ],
                                  ),
                                  textColor: Colors.white,
                                  color: Colors.black),
                              SizedBox(width: 10,),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0,
                                    right: 0.0,
                                    top: 0.0,
                                    bottom: 0.0),
                                child: new RaisedButton(
                                    elevation: 0.0,
                                    shape: new RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(5.0)),
                                    padding: EdgeInsets.only(
                                        top: 1.0,
                                        bottom: 1.0,
                                        right: 3.0,
                                        left: 3.0),
                                    onPressed: () {
                                      launch("tel:${mobile}");
                                      /*Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => CourierMapPage(
                                                    deliveryboyid: deliveryboyid,
                                                    courierid: courierId,
                                                    destinationLat: destLat,
                                                    destinationLng: destLng,
                                                  )));*/
                                    },
                                    child: new Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(Icons.call),
                                        Padding(
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: new Text(
                                              "Call",
                                              style: TextStyle(
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold),
                                            ))
                                      ],
                                    ),
                                    textColor: Colors.white,
                                    color: Colors.green),
                              ),
                            ],
                          ),
                        )
                      : orderStatus == "Pending"
                          ? Container(
                              padding: EdgeInsets.only(right: 10, top: 5),
                              child: GestureDetector(
                                onTap: () {
                                  _showMyDialog(courierId, context);
                                },
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        S.of(context).cancel,
                                        style: TextStyle(
                                            fontSize: 13.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                              ),
                            )
                          : SizedBox(
                              height: 5,
                            )
                ],
              ),
            )));
  }

  void postCustomerCancel(String orderId, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString('id');
    Map data;
    final http.Response response = await http.post(
      Strings.baseUrl + 'Courrier/courrierCancel',
      body: {'courierid': orderId, 'app_user_id': userId},
    );

    data = jsonDecode(response.body);
    try {
      if (data["resultcode"] == "200") {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e);
    }
  }
}
