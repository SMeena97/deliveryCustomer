import 'dart:async';
import 'dart:convert';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:io' show Platform;

class NotificationsWidget extends StatefulWidget {

  final GlobalKey<ScaffoldState> parentScaffoldKey;
   NotificationsWidget({Key key, this.parentScaffoldKey}) : super(key: key);
  @override
  _NotificationsWidgetState createState() => _NotificationsWidgetState();

 
}

class _NotificationsWidgetState extends State<NotificationsWidget> {
  var deviceid;
  TextEditingController title = new TextEditingController();
  TextEditingController message = new TextEditingController();
  String my_title = "";
  String my_message = "";
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  var firebaseUser = FirebaseAuth.instance.currentUser;

  StreamSubscription iosSubscription;
  String deviceTok;
  @override
  void initState() {
     if (Platform.isIOS) {
       iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
         print(data);
         _getToken();
       });
       _fcm.requestNotificationPermissions(IosNotificationSettings());
     } else {
     _getToken();
     }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // Scaffold.of(context).showSnackBar(snackbar);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.amber,
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );
  }

  @override
  void dispose() {
    if (iosSubscription != null) iosSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _handleMessages(context);
    return Scaffold(
        appBar: AppBar(title: Text('Notification Page')),
        body: IndexedStack(children: <Widget>[
          Container(
            child: new Column(children: [
              TextFormField(
                controller: title,
                decoration: InputDecoration(hintText: 'Enter title'),
              ),
              TextFormField(
                controller: message,
                decoration: InputDecoration(hintText: 'Enter message'),
              ),
              RaisedButton(
                  elevation: 0.0,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0)),
                  padding: EdgeInsets.only(
                      top: 1.0, bottom: 1.0, right: 3.0, left: 3.0),
                  onPressed: () {
                    setState(() {
                      my_title = title.text;
                      my_message = message.text;
                    });
                    sendAndRetrieveMessage(my_title, my_message);
                  },
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: new Text(
                            "Send",
                            style: TextStyle(
                                fontSize: 13.0, fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                  textColor: Colors.white,
                  color: Colors.redAccent),
            ]),
          )
        ]));
  }

  _getToken() {
    _fcm.getToken().then((deviceToken) {
      print("Device token");
      print(deviceToken);
      deviceid = deviceToken;
      setState(() {
        this.deviceTok=deviceToken;
      });
    });
  }

  /// Get the token, save it to the database for current user

}
Future<Map<String, dynamic>> sendAndRetrieveMessage(notification_title, notification_message) async {
print('input message');
print(notification_title);
print(notification_message);
// Replace with server token from firebase console settings.
  var my_title = notification_title;
  var my_message = notification_message;

  // 'eiN_lY5RRsGoX8c_o9zVHH:APA91bFXLYzAWs6QzPNkZs_CrEuKGBA-mIYm9somMRDJYCGeB1egt4j7599dtbAlSig1M5bJz_O0e4kDuK_1DQOqdRh7kA87PzyuEbQFAP3uhkU6P_jLRknbn067joQvb43kQlLujbEr';
      // 'AAAA3hrv_8A:APA91bHe4OmE3LxzuvUOhY2UCdbEw8u4HxcI98OXbQs8ZVQJpNNRFrgoM_wDBDDTK_GalKtlQUAJnTgt6JYxw9LiZE-1R5oKQQVSaM5wjuZlvrpo2z6Yb1ZLNMs_w906Rd-nKtBlF68-';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final String serverToken = await firebaseMessaging.getToken();
  print('serverToken...');
  print(serverToken);
  await firebaseMessaging.requestNotificationPermissions(
    const IosNotificationSettings(
        sound: true, badge: true, alert: true, provisional: false),
  );

  await post(
    'https://fcm.googleapis.com/fcm/send',
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverToken',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': my_title,
          'title': my_message
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done'
        },
        'to': await firebaseMessaging.getToken(),
      },
    ),
  );

  final Completer<Map<String, dynamic>> completer =
      Completer<Map<String, dynamic>>();

  firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      completer.complete(message);
    },
  );

  return completer.future;
}