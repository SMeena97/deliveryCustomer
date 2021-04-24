import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/generated/l10n.dart';
import 'package:food_delivery_app/src/elements/courier_myorder.dart';
import 'package:food_delivery_app/src/models/courier_myorder.dart';
import 'package:food_delivery_app/src/repository/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/helper.dart';

class CourierHome extends StatefulWidget {
  @override
  _CourierHomeState createState() => _CourierHomeState();
}

class _CourierHomeState extends State<CourierHome> {
  String destinationLat;
  String destinationLng;

  Future<CourierMyOrderModel> _myorder;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 5));

    setState(() {
      _myorder = API_Manager().getCourierMyorder();
    });

    return null;
  }

  _loadApi() {
    if(mounted){
      setState(() {
        _myorder = API_Manager().getCourierMyorder();
      });
    }
  }

  @override
  void initState() {
    super.initState();
      _myorder = API_Manager().getCourierMyorder();
    // const fiveSeconds = const Duration(seconds: 5);
    // /*if (mounted)*/ Timer.periodic(fiveSeconds, (Timer t) => _loadApi());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
       onWillPop: Helper.of(context).onWillPop,
          child: Scaffold(
        appBar: new AppBar(
            backgroundColor: Colors.white,
            leading: Container(),
            title: new Text("Courier Delivery",
                style: TextStyle(color: Colors.black)),
            actions: [
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () async {
                    Navigator.pushNamed(context, '/courierLanguage');
                  }),
              IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    SystemNavigator.pop();
                  }),
            ]),
        body: RefreshIndicator(
            key: refreshKey,
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                child: FutureBuilder<CourierMyOrderModel>(
                    future: _myorder,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data.result.length,
                            itemBuilder: (context, index) {
                              var out = snapshot.data.result[index];
                              out.status == 'Pending' || out.status == 'Confirmed'
                                  ? {
                                      this.destinationLat = out.pickupLat,
                                      this.destinationLng = out.pickupLng
                                    }
                                  : {
                                      this.destinationLat = out.deliveryLat,
                                      this.destinationLng = out.delBoyLng
                                    };
                              var date = out.couriertime.toString();
                              var sp = date.split(" ");
                              var spTime = sp[1].split(".");

                              
                              return CourierMyOrder(
                                courierId: out.courierid,
                                orderTime: sp[0],
                                orderStatus: out.status,
                                deliveryboyid: out.deliveryboyid ?? '0',
                                destLat: destinationLat,
                                destLng: destinationLng,
                                mobile: out.dmobile,
                                time: sp[1],
                              );
                            });
                      } else if (!snapshot.hasData) {
                        return Center(child: Text('No Order'));
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    })),
            onRefresh: refreshList,
          
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/Pickupcourier');
          },
          child: Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

Widget listItemValue(BuildContext context, int index) {
  String mapimg = 'assets/images/pin.svg';
  String chatimg = 'assets/images/chat.svg';
  return new Card(
      elevation: 10,
      child: new Column(
        children: <Widget>[
          new Container(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new Text(
                          S.of(context).courier_id+':',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  flex: 3,
                ),
                Expanded(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        new Text(
                          '100',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  flex: 2,
                ),
                Expanded(
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          new Text(
                            "Order Status" + ':',
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          )
                        ],
                      ),
                    ),
                    flex: 3),
                Expanded(
                    child: Container(
                      padding: EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          new Text(
                            'Status',
                            style: TextStyle(fontSize: 14, color: Colors.green),
                          )
                        ],
                      ),
                    ),
                    flex: 2),
              ],
            ),
          ),
          new Container(
            padding: EdgeInsets.only(left: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new Text(
                          "Order Time" + ':',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        )
                      ],
                    ),
                  ),
                  flex: 3,
                ),
                Expanded(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        new Text(
                          '10:30',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        )
                      ],
                    ),
                  ),
                  flex: 7,
                ),
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new RaisedButton(
                  elevation: 0.0,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),
                  padding: EdgeInsets.only(
                      top: 1.0, bottom: 1.0, right: 3.0, left: 3.0),
                  onPressed: () {},
                  child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new SvgPicture.asset(
                        chatimg,
                        height: 20.0,
                        width: 20.0,
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: new Text(
                            "Chat",
                            style: TextStyle(
                                fontSize: 13.0, fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                  textColor: Colors.white,
                  color: Colors.black),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 0.0, top: 0.0, bottom: 0.0),
                child: new RaisedButton(
                    elevation: 0.0,
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(5.0)),
                    padding: EdgeInsets.only(
                        top: 1.0, bottom: 1.0, right: 3.0, left: 3.0),
                    onPressed: () {},
                    child: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new SvgPicture.asset(
                          mapimg,
                          height: 20.0,
                          width: 20.0,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: new Text(
                              "Call",
                              style: TextStyle(
                                  fontSize: 13.0, fontWeight: FontWeight.bold),
                            ))
                      ],
                    ),
                    textColor: Colors.white,
                    color: Colors.redAccent),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ));
}
