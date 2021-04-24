import 'package:flutter/material.dart';
import 'package:food_delivery_app/generated/l10n.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Courier extends StatefulWidget {
  @override
  _CourierState createState() => _CourierState();
}

class _CourierState extends State<Courier> {
  Widget _buildBanner() {
    return Container(
      height: 160,
      child: Image.asset('assets/images/delivery_banner.jpg'),
    );
  }

  navigateService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('id')) {
      Navigator.of(context).pushReplacementNamed('/courierHome');
    } else {
      Navigator.of(context).pushNamed('/Login');
    }
  }

  Widget _buildCard1() {
    return GestureDetector(
        onTap: () {
          navigateService();
        },
        child: Card(
            elevation: 7,
            color: Colors.amber[50],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                children: [
                  Container(
                      color: Colors.amber[50],
                      child: Image.asset('assets/images/courier.png',
                          width: 50, height: 50)),
                  SizedBox(width: 30),
                  Column(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.60,
                          child: Text(
                            S.of(context).send_package,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                      SizedBox(height: 6),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.60,
                          child: Text(S.of(context).send_anywhere))
                    ],
                  )
                ],
              ),
            )));
  }

  Widget _buildCard2() {
    return GestureDetector(
        onTap: () {
          // Navigator.of(context).pushReplacementNamed('/Pages', arguments: 2);
          Navigator.of(context)
              .pushReplacementNamed('/categories', arguments: 2);
        },
        child: Card(
            elevation: 7,
            color: Colors.amber[50],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                children: [
                  Image.asset('assets/images/food.png', width: 50, height: 50),
                  SizedBox(width: 30),
                  Column(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width * 0.60,
                          child: Text(
                            S.of(context).get_delivery,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )),
                      SizedBox(height: 6),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.60,
                          child: Text(S.of(context).order_delivery))
                    ],
                  )
                ],
              ),
            )));
  }

  @override
  void initState() {
    super.initState();
    _getPermission();
  }

  _getPermission() async {
    await Permission.locationAlways.request();
    PermissionStatus permission = await Permission.locationAlways.status;
    if (permission.isGranted) {
      print("Permission Granted");
    } else {
      print("Permission not granted");
      await Permission.locationAlways.request();
      PermissionStatus permission = await Permission.locationAlways.status;
      if (permission.isGranted) {
        print("Permission Granted");
      } else {
        print("Permission not granted");
        await Permission.locationAlways.request();
        PermissionStatus permission = await Permission.locationAlways.status;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: new AppBar(
              leading: Container(),
              backgroundColor: Colors.white,
              title: new Text(S.of(context).welcome,
                  style: TextStyle(color: Colors.black)),
            ),
            body: Container(
                child: Column(
              children: [
                SizedBox(height: 10),
                _buildBanner(),
                SizedBox(height: 10),
                _buildCard1(),
                SizedBox(height: 10),
                _buildCard2()
              ],
            ))));
  }
}
