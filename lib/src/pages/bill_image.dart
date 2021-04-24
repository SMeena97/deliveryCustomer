import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BillImage extends StatefulWidget {
  final String orderId;
  const BillImage({
    Key key,
    @required this.orderId,
  }) : super(key: key);


  @override
  _BillImageState createState() => _BillImageState();
}



class _BillImageState extends State<BillImage> {

  String imageUrl;

  Future<void> getBillImage() async {
  Map data;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String id=prefs.getString("id");
  final String url = '${GlobalConfiguration().getValue('local_url')}AppUserProfile/loadBillImage?id=$id&orderid=${widget.orderId}';
   print("url"+url);
  final client = new http.Client();
  final response = await client.get(
    url,
  );
  data=json.decode(response.body);

  print("billres"+data.toString());
  try{
  if (data["resultcode"]=="200") {
    setState(() {
      imageUrl=data["result"]["bill_image"];
    });   
  } else {
  
  }}catch(e){ 
    print(e);
  }
  
}

  @override
  void initState() {
    getBillImage();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:Scaffold(
        appBar:AppBar(
          title: const Text('Your Bill'),
        ),
        body:imageUrl!=null ? Container( 
          child:Image.network(imageUrl)
        ):Center(child: CircularProgressIndicator())
      )
    );
  }
}