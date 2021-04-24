import 'package:flutter/material.dart';

class CourierSuccess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
       onWillPop: () async => false,
    child:Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
         
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'confirmation',
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),
     body:Center(
       child:Column(children: [ 
         Stack(
                          children: <Widget>[
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, colors: [
                                    Colors.green.withOpacity(1),
                                    Colors.green.withOpacity(0.2),
                                  ])),
                            
                                 
                                  child: Icon(
                                      Icons.check,
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      size: 90,
                                    ),
                            ),
                            Positioned(
                              right: -30,
                              bottom: -50,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(150),
                                ),
                              ),
                            ),
                            Positioned(
                              left: -20,
                              top: -50,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(150),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 15),
                        Opacity(
                          opacity: 0.4,
                          child: Text(
                            'Your order has been successfully submitted',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline3.merge(TextStyle(fontWeight: FontWeight.w300)),
                          ),
                        ),
                        SizedBox(height: 20,),
                         FlatButton(                          
                                onPressed: () {
                                  Navigator.of(context).pushReplacementNamed('/courierHome');
                                },
                                padding: EdgeInsets.symmetric(vertical: 14),
                                color: Theme.of(context).accentColor,
                                shape: StadiumBorder(),
                                child: Text(
                                   'My Order',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(color: Theme.of(context).primaryColor),
                                ),
                              )
       ],)
    
    )));
  }
}