import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/models/coupon_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/CartItemWidget.dart';
import '../elements/EmptyCartWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../models/coupon_model.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

import 'package:http/http.dart' as http;

class CartWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  CartWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends StateMVC<CartWidget> {
  CartController _con;

  _CartWidgetState() : super(CartController()) {
    _con = controller;
  }

  CouponModel couponObj;
  Future<http.Response> _responseFuture;
  TextEditingController couponController=new TextEditingController();

  Color iconColor = Colors.grey;
  String couponCheck = '';

  @override
  void initState() {
    super.initState();
    _con.listenForCarts();
    _con.calculateSubtotal();
    // setCard();
  }

  getLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!currentUser.value.auth) {
        Navigator.of(context).pushNamed('/Login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con.scaffoldKey,
        bottomNavigationBar: CartBottomDetailsWidget(con: _con),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
              /*if (widget.routeArgument != null) {
                Navigator.of(context).pushReplacementNamed(widget.routeArgument.param, arguments: RouteArgument(id: widget.routeArgument.id));
              } else {
                Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
              }*/
            },
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).hintColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            S.of(context).cart,
            style: Theme.of(context)
                .textTheme
                .headline6
                .merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: !currentUser.value.auth
            ? PermissionDeniedWidget()
            : RefreshIndicator(
                onRefresh: _con.refreshCarts,
                child: _con.carts.isEmpty
                    ? EmptyCartWidget()
                    : Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          ListView(
                            primary: true,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 20, right: 10),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 0),
                                  leading: Icon(
                                    Icons.shopping_cart,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).shopping_cart,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.headline4,
                                  ),
                                ),
                              ),
                              ListView.separated(
                                padding: EdgeInsets.only(top: 15, bottom: 120),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                primary: false,
                                itemCount: _con.carts.length,
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 15);
                                },
                                itemBuilder: (context, index) {
                                  return CartItemWidget(
                                    cart: _con.carts.elementAt(index),
                                    heroTag: 'cart',
                                    increment: () {
                                      _con.incrementQuantity(
                                          _con.carts.elementAt(index));
                                    },
                                    decrement: () {
                                      _con.decrementQuantity(
                                          _con.carts.elementAt(index));
                                    },
                                    onDismissed: () {
                                      _con.removeFromCart(
                                          _con.carts.elementAt(index));
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(18),
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.15),
                                      offset: Offset(0, 2),
                                      blurRadius: 5.0)
                                ]),
                            child: TextField(
                              keyboardType: TextInputType.text,
                              onSubmitted: (String value) {
                                _couponApply(value,context);
                              },
                              cursorColor: Theme.of(context).accentColor,
                              controller: couponController
                                /*..text = couponObj?.couponcode ?? ''*/,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                hintStyle:
                                    Theme.of(context).textTheme.bodyText1,
                                suffixText:couponCheck /*_con.getCouponStatus()*/,
                                suffixStyle: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .merge(TextStyle(
                                        color: _con.getCouponIconColor())),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Icon(
                                    Icons.confirmation_number,
                                    color: /*_con.getCouponIconColor()*/ iconColor,
                                    size: 28,
                                  ),
                                ),
                                hintText: S.of(context).haveCouponCode,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5))),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.2))),
                              ),
                            ),
                          ),
                          Container(
                              height: 30,
                              padding: EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.15),
                                        offset: Offset(0, 2),
                                        blurRadius: 5.0)
                                  ]),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                    onTap: () {
                                      print("restaurantId" +
                                          _con.restaurant_id.toString());
                                      _responseFuture = http.post(
                                          Strings.baseUrl +
                                              'Coupon/loadCoupons?user_id=' +
                                              _con.restaurant_id.toString());
                                      _con.scaffoldKey.currentState
                                          .showBottomSheet((context) {
                                        return Container(
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              SingleChildScrollView(
                                                child: new FutureBuilder(
                                                  future: _responseFuture,
                                                  builder:
                                                      (BuildContext context,
                                                          AsyncSnapshot<dynamic>
                                                              response) {
                                                    if (!response.hasData) {
                                                      return Center(
                                                        child:
                                                            Text("No Coupon"),
                                                      );
                                                    } else if (response
                                                            .data.statusCode !=
                                                        200) {
                                                      return const Center(
                                                        child: const Text(
                                                            'Error loading data'),
                                                      );
                                                    } else {
                                                      Map<String, dynamic>
                                                          json = jsonDecode(
                                                              response
                                                                  .data.body);
                                                      if (json["resultcode"] ==
                                                          "200") {
                                                        List<dynamic> data =
                                                            json["result"];
                                                        List<Widget>
                                                            reasonList = [];
                                                        data.forEach((element) {
                                                          reasonList
                                                              .add(new ListTile(
                                                            title: Container(
                                                              child: new Card(
                                                                  child: new Column(
                                                                      children: [
                                                                    new Container(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              10,
                                                                          top:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                Container(
                                                                                  padding: EdgeInsets.only(left: 10),
                                                                                  child: new Text(
                                                                                    element["couponcode"],
                                                                                    style: TextStyle(
                                                                                      fontSize: 15,
                                                                                      color: Colors.black,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  padding: EdgeInsets.only(left: 10),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      new Text(
                                                                                        'Coupon code',
                                                                                        style: TextStyle(
                                                                                          fontSize: 11,
                                                                                          color: Colors.black54,
                                                                                        ),
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    new Container(
                                                                      child:
                                                                          Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                new Container(
                                                                                    padding: EdgeInsets.only(left: 10),
                                                                                    child: Row(
                                                                                      mainAxisSize: MainAxisSize.max,
                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                      children: [
                                                                                        new Container(
                                                                                          padding: EdgeInsets.only(left: 10),
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              new Text(
                                                                                                element["type"] != "amount" ? element["rate"] + " % OFF" : element["rate"] + " Rs only",
                                                                                                style: TextStyle(fontSize: 13, color: Colors.green),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    )),
                                                                                SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                new Container(
                                                                                    padding: EdgeInsets.only(left: 20, bottom: 10),
                                                                                    child: Align(
                                                                                      alignment: Alignment.centerLeft,
                                                                                      child: new Text("its available for " + element["coupon_usage"] + " times only",
                                                                                          style: GoogleFonts.openSans(
                                                                                            textStyle: TextStyle(fontSize: 11, color: Colors.black54),
                                                                                          )),
                                                                                    ))
                                                                              ],
                                                                            ),
                                                                            flex:
                                                                                6,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.only(right: 10),
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  FlatButton(
                                                                                    child: Text(
                                                                                      "Apply",
                                                                                      style: TextStyle(color: Colors.green),
                                                                                    ),
                                                                                    onPressed: () {
                                                                                      _couponApply(element["couponcode"],context);
                                                                                    },
                                                                                  )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            flex:
                                                                                4,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ])),
                                                            ),
                                                          ));
                                                        });
                                                        return new Column(
                                                            children:
                                                                reasonList);
                                                      } else {
                                                        return Center(
                                                          child:
                                                              Text("No Coupon"),
                                                        );
                                                      }
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                    },
                                    child: Text(
                                      "Check Available Coupon",
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 11),
                                    )),
                              ))
                        ],
                      ),
              ),
      ),
    );
  }


  _couponApply(String couponCode, BuildContext context) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _con.doApplyCoupon(couponCode);
    if( prefs.getString("couponApplied")=="1"){
      if(prefs.getDouble('couponCode')!=0.0){
        couponController.text=couponCode;
        setState(() {
          iconColor = Colors.green;
          couponCheck = 'Coupon Valid';
          prefs.setDouble('couponCode', 0.0);
        });
        Navigator.pop(context);
      }
    }
    else if(prefs.getString("couponApplied")=="0"){
      couponController.text="";
      setState(() {
        iconColor = Colors.redAccent;
        couponCheck = 'Coupon Invalid';
        prefs.setDouble('couponCode', 0.0);
      });
      Navigator.pop(context);
    }
  }
}
