import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_delivery_app/src/chat/const.dart';
import 'package:food_delivery_app/src/pages/open_order_cart.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../repository/user_repository.dart';
import '../../generated/l10n.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/FoodItemWidget.dart';
import '../elements/FoodsCarouselWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  MenuWidget({Key key, this.parentScaffoldKey, this.routeArgument})
      : super(key: key);
}

class _MenuWidgetState extends StateMVC<MenuWidget> {
  RestaurantController _con;
  List<String> selectedCategories;

  _MenuWidgetState() : super(RestaurantController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.restaurant = widget.routeArgument.param as Restaurant;
    _con.listenForTrendingFoods(_con.restaurant.id);
    selectedCategories = ['0'];
    _con.listenForFoods(_con.restaurant.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
          onPressed: () => Navigator.of(context).pushNamed('/Details',
              arguments: RouteArgument(
                  id: '0', param: _con.restaurant.id, heroTag: 'menu_tab')),
        ),
        title: Text(
          _con.restaurant?.name ?? '',
          overflow: TextOverflow.fade,
          softWrap: false,
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 0)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarWidget(),
            ),
            ListTile(
              dense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: Icon(
                Icons.subject,
                color: Theme.of(context).hintColor,
              ),
              title: Text(
                S.of(context).all_menu,
                style: Theme.of(context).textTheme.headline4,
              ),
              subtitle: Text(
                S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
                maxLines: 2,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 10, bottom: 10),
              alignment: Alignment.centerRight,
              child: RaisedButton(
                color: Colors.orange[900],
                onPressed: () {
                  if (currentUser.value.auth) {
                    if (currentUser.value.lat != "" &&
                        currentUser.value.lng != "") {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OpenOrderCart(
                                  restaurantId: _con.restaurant.id,
                                  lat: _con.restaurant.latitude,
                                  lng: _con.restaurant.longitude)));
                    } else {
                      Navigator.of(context).pushNamed('/Settings');
                    }
                  } else {
                    Navigator.of(context).pushNamed('/Login');
                  }
                },
                child: const Text('Open Order',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            _con.foods.isEmpty
                ? CircularLoadingWidget(height: 250)
                : ListView.separated(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: _con.foods.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 10);
                    },
                    itemBuilder: (context, index) {
                      return FoodItemWidget(
                        heroTag: 'menu_list',
                        food: _con.foods.elementAt(index),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
