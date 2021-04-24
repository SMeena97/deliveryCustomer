import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter/services.dart';
import '../../generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class Support extends StatefulWidget {
  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<Support> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterOpenWhatsapp.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            S.of(context).help_support,
            style: Theme.of(context)
                .textTheme
                .headline6
                .merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
        body: Container(
            width: MediaQuery.of(context).size.width,
            child: Card(
                child: Column(children: [
              Container(
                  height: MediaQuery.of(context).size.height * 0.50,
                  child: Image.asset('assets/images/support.jpg',
                      fit: BoxFit.cover)),
              Container(
           
                child: Row(               
                  children: [                    
                       Container(
                         width:MediaQuery.of(context).size.height * 0.25,
                         child: MaterialButton(
                          onPressed: () {
                            FlutterOpenWhatsapp.sendSingleMessage(
                                "967733189114", "Hi");
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.height * 0.25,
                            child: Image.asset(
                              'assets/images/whatsapp.jpg',
                              fit: BoxFit.fill,
                            ),
                          ),
                      ),
                       ),
                                    
                      Container(
                        width:MediaQuery.of(context).size.height * 0.16,
                        child: MaterialButton(
                          onPressed: () {
                             launch("tel:967733189114");
                          },
                          child:Container(
                            width:MediaQuery.of(context).size.height * 0.16,
                            child: Image.asset(
                              'assets/images/call.jpg',
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                    
                  ],
                ),
              )
            ]))));
  }
}


