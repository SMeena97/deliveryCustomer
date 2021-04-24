import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/PermissionDeniedWidget.dart';
import '../models/conversation.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';
import 'chat.dart';
import 'map.dart';
import 'menu_list.dart';
import 'restaurant.dart';

class DetailsWidget extends StatefulWidget {
  RouteArgument routeArgument;
  dynamic currentTab;
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  Widget currentPage;

  DetailsWidget({
    Key key,
    this.currentTab,
  }) {
    if (currentTab != null) {
      if (currentTab is RouteArgument) {
        routeArgument = currentTab;
        currentTab = int.parse(currentTab.id);
      }
    } else {
      currentTab = 0;
    }
  }

  @override
  _DetailsWidgetState createState() {
    return _DetailsWidgetState();
  }
}

class _DetailsWidgetState extends StateMVC<DetailsWidget> {
  RestaurantController _con;

  _DetailsWidgetState() : super(RestaurantController()) {
    _con = controller;
  }

  initState() {
    _selectTab(widget.currentTab);
    super.initState();
  }

  @override
  void didUpdateWidget(DetailsWidget oldWidget) {
    _selectTab(oldWidget.currentTab);
    super.didUpdateWidget(oldWidget);
  }

  void _selectTab(int tabItem) {
    setState(() {
      widget.currentTab = tabItem;
      switch (tabItem) {
        case 0:
          _con.listenForRestaurant(id: widget.routeArgument.param).then((value) {
            setState(() {
              _con.restaurant = value as Restaurant;
              print(_con.restaurant.toMap());
              widget.currentPage = RestaurantWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: RouteArgument(param: _con.restaurant));
            });
          });
          break;
        case 1:
          if (currentUser.value.auth) {
            widget.currentPage = PermissionDeniedWidget();
          } else {
            Conversation _conversation = new Conversation(
                _con.restaurant.users.map((e) {
                  e.image = _con.restaurant.image;
                  return e;
                }).toList(),
                name: _con.restaurant.name);
            widget.currentPage = ChatWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: RouteArgument(id: _con.restaurant.id, param: _conversation));
          }
          break;
        case 2:
          widget.currentPage = MapWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: RouteArgument(param: _con.restaurant));
          break;
        case 3:
          widget.currentPage = MenuWidget(parentScaffoldKey: widget.scaffoldKey, routeArgument: RouteArgument(param: _con.restaurant));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: widget.scaffoldKey,
        drawer: DrawerWidget(),
        bottomNavigationBar: Container(
          height: 66,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withOpacity(0.10), offset: Offset(0, -4), blurRadius: 10)],
          ),
          child: Container(
              padding:EdgeInsets.all(10),
              width:MediaQuery.of(context).size.width,       
              child:FlatButton(              
                onPressed: () {
                  this._selectTab(3);
                },               
                shape: StadiumBorder(),
                color: Theme.of(context).accentColor,
                child: Wrap(
                  spacing: 10,
                  children: [
                    Icon(Icons.menu_book, color: Theme.of(context).primaryColor),
                    Text(
                      S.of(context).menu,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    )
                  ],
                ),
              ),
            
          ),
        ),
        body: widget.currentPage ?? CircularLoadingWidget(height: 400));
  }
}
