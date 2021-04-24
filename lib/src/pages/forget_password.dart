import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;
import '../helpers/helper.dart';
import 'package:http/http.dart' as http;

class ForgetPasswordWidget extends StatefulWidget {
  @override
  _ForgetPasswordWidgetState createState() => _ForgetPasswordWidgetState();
}

class _ForgetPasswordWidgetState extends StateMVC<ForgetPasswordWidget> {
  UserController _con;
  TextEditingController phonecontroller = TextEditingController();
  Map data;
  String resultCode;
  String resultmessage;
  _ForgetPasswordWidgetState() : super(UserController()) {
    _con = controller;
  }

  _resetPassword() async {
    final signcode=await SmsAutoFill().getAppSignature;
    print(signcode);
    // Navigator.of(context).pushReplacementNamed('/ForgetPasswordInput');
    var client = http.Client();
    try {
      String url = Strings.baseUrl + 'AppUserProfile/sendOTP';
      var response = await client.post(url, body: {
        'mobile': phonecontroller.text,
        'code':signcode
      });
      if(response.statusCode==200){
        data=jsonDecode(response.body);
        resultCode=data["resultcode"];
        resultmessage=data["resultmessage"];
        if(resultCode=="200"){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SMSAutoVerify(phonecontroller.text,signcode)));
        }else{
          Fluttertoast.showToast(msg: resultmessage);
        }
      }
    }catch(ex){
      print(ex);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(37),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 120,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(37),
                child: Text(
                  "Mobile Number to reset password",
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 50,
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      )
                    ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: phonecontroller,
                        // onSaved: (input) => _con.user.email = input,
                        // validator: (input) => !input.contains('H') ? S.of(context).should_be_a_valid_email : null,
                        decoration: InputDecoration(
                          labelText: "Phone",
                          labelStyle:
                              TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '1234567890',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.phone,
                              color: Theme.of(context).accentColor),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      BlockButtonWidget(
                        text: Text(
                          "Send OTP",
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          _resetPassword();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              child: Column(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/Login');
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(
                        S.of(context).i_remember_my_password_return_to_login),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/SignUp');
                    },
                    textColor: Theme.of(context).hintColor,
                    child: Text(S.of(context).i_dont_have_an_account),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}



class ForgetPasswordInputWidget extends StatefulWidget {
  var otp;

  var id;

  ForgetPasswordInputWidget(this.id,this.otp);

  @override
  _ForgetPasswordInputWidgetState createState() => _ForgetPasswordInputWidgetState(id,otp);
}

class _ForgetPasswordInputWidgetState extends StateMVC<ForgetPasswordInputWidget> {
  UserController _con;
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordCcontroller = TextEditingController();
  bool _passwordVisible=false;
  bool _confirmVisible=false;
  String otp;
  String id;
  Map data;
  String resultCode;
  String resultmessage;

  _ForgetPasswordInputWidgetState(this.id, this.otp);

  _resetPassword() async {
    var client = http.Client();
    try {
      String url = Strings.baseUrl + 'AppUserProfile/forgotAppUserPassword';
      var response = await client.post(url, body: {
        'otp':otp,
        'app_user_id':id,
        'newpassword':confirmPasswordCcontroller.text,
      });
      if(response.statusCode==200){
        data=jsonDecode(response.body);
        resultCode=data["resultcode"];
        resultmessage=data["resultmessage"];
        if(resultCode=="200"){
          Navigator.of(context).pushReplacementNamed('/Courier');
        }else{
          Fluttertoast.showToast(msg: resultmessage);
        }
      }
    }catch(ex){
    }
  }

  @override
  void initState() {
    _passwordVisible = false;
    _confirmVisible = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(37),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 120,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(37),
                child: Text(
                  "Reset password",
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 50,
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      )
                    ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _passwordVisible,
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          labelText: "Enter New Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                          labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '******',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: confirmPasswordCcontroller,
                        obscureText: _confirmVisible,
                        decoration: InputDecoration(
                          labelText: "Enter Confirm Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Based on passwordVisible state choose the icon
                              _confirmVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _confirmVisible = !_confirmVisible;
                              });
                            },
                          ),
                          labelStyle:
                          TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '******',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          /*prefixIcon: Icon(Icons.phone,
                              color: Theme.of(context).accentColor),*/
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      BlockButtonWidget(
                        text: Text(
                          "Submit",
                          style:
                          TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          if(newPasswordController.text.isEmpty){
                            Fluttertoast.showToast(
                                msg: "Please enter New Password",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }else if(confirmPasswordCcontroller.text.isEmpty){
                            Fluttertoast.showToast(
                                msg: "Please enter Confirm Password",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }else if(newPasswordController.text!=confirmPasswordCcontroller.text){
                            Fluttertoast.showToast(
                                msg: "Please enter Same password in confirm field",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }else{
                            _resetPassword();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class SMSAutoVerify extends StatefulWidget {
  var signcode;
  var text;

  SMSAutoVerify(this.text,this.signcode);

  @override
  _SMSAutoVerifyState createState() => _SMSAutoVerifyState(text,signcode);
}

class _SMSAutoVerifyState extends State<SMSAutoVerify> {
  String mobileNumber;
  String code;
  String otp;
  Map data;
  String resultCode;
  String resultmessage;

  _SMSAutoVerifyState(this.mobileNumber, this.code);

  _resetPassword(String mobile,String msgcode) async {
    var client = http.Client();
    try {
      String url = Strings.baseUrl + 'AppUserProfile/sendOTP';
      var response = await client.post(url, body: {
        'mobile': mobile,
        'code':msgcode
      });
      if(response.statusCode==200){
        data=jsonDecode(response.body);
        resultCode=data["resultcode"];
        resultmessage=data["resultmessage"];
        if(resultCode=="200"){
        }else{
          Fluttertoast.showToast(msg: resultmessage);
        }
      }
    }catch(ex){
      print(ex);
    }
  }

  _sendOTPtoServer(String otp) async {
    var client = http.Client();
    try {
      String url = Strings.baseUrl + 'AppUserProfile/checkOTP';
      var response = await client.post(url, body: {
        'otp': otp,
      });
      if(response.statusCode==200){
        data=jsonDecode(response.body);
        resultCode=data["resultcode"];
        resultmessage=data["resultmessage"];
        if(resultCode=="200"){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ForgetPasswordInputWidget(data["result"]["app_user_id"],data["result"]["otp"])));
          // Navigator.of(context).pushReplacementNamed('/ForgetPasswordInput');
        }else{
          Fluttertoast.showToast(msg: resultmessage);
        }
      }
    }catch(ex){
      print(ex);
    }
  }

  _listionOtp()async{
    await SmsAutoFill().listenForCode;
  }

  @override
  void initState() {
    _listionOtp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: Helper.of(context).onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(37),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 120,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(37),
                child: Text(
                  "Reset password",
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 50,
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      )
                    ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text('Registered Mobile Number is $mobileNumber'),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 30,horizontal: 10),
                        child: PinFieldAutoFill(
                          codeLength: 6,
                          onCodeChanged: (val){
                            otp=val;
                            print(val);
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: InkWell(
                          onTap: (){
                            _resetPassword(mobileNumber, code);
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("Resend OTP",style: TextStyle(color: Colors.red,fontSize: 10),),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      BlockButtonWidget(
                        text: Text(
                          "Verify",
                          style:
                          TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                            if (otp.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: "Please enter OTP",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else if (otp.length != 6) {
                              Fluttertoast.showToast(
                                  msg: "Please enter valid OTP number",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            } else {
                              _sendOTPtoServer(otp);
                            }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 /* void _onChange(String val) {
    setState(() {
      otp=val;
    });
  }*/
}
