import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/models/login_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}
 
class _LoginState extends State<Login> {

     String error='';
  final _formKey = GlobalKey<FormState>();

   final usernameController = TextEditingController();
    final passwordController = TextEditingController();
  
  void navigateService(){
      if (_formKey.currentState.validate()) {
    getLogin(usernameController.text,passwordController.text);
      }
  }

  Future<LoginModel> getLogin(String username,String password) async {
    var client = http.Client();
    var code;
    var out;
    Map data;
    try {
     String url=Strings.baseUrl+'AppUserProfile/loginAppUser?app_user_email=$username&app_user_password=$password';
      var response = await client.get(url);
       print('reswe'+jsonDecode(response.body));
      if (response.statusCode == 200) { 
        print('coiurier login');
        data=jsonDecode(response.body);
         SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString("id",data["result"]["app_user_id"]);
          print(prefs.getString("id"));
        print(response.body);
        // out=LoginModel.fromJson(jsonDecode(response.body));
       print("1");
         Navigator.of(context).pushReplacementNamed('/courierHome');
        //  code = LoginModel.fromJson(jsonDecode(response.body)).resultcode;
        //     var userId=LoginModel.fromJson(jsonDecode(response.body)).result.appUserId;
        //     _store(userId);             
      }
      else{
        setState(() {
               error='Invalid Username or Password';
             });
      }
    } catch (Exception) {
      return out;
    }
    return out;
  }

   

  @override
  Widget build(BuildContext context) {
    return SafeArea(
    child:Scaffold(  
      backgroundColor: Colors.black,  
      body: Center(
        child: loginBody(),
      ),
    ));
  }

  loginBody() => SingleChildScrollView(
    child:Column(children: [ 
      Container(
        child:Column(children: [ 
          SizedBox(height:10),
           SvgPicture.asset("assets/images/logo.svg",width:80),
        
          SizedBox(height:25)
        ],)
        ),
        Card( 
          shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
         ),       
          margin: EdgeInsets.symmetric(horizontal:30),
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[loginHeader(), loginFields()],
          ),
        ),
        SizedBox(height:20),
        Container(
          child:GestureDetector (
            onTap:(){
            //  Navigator.pushNamed(context, '/courierSignup');
            Navigator.of(context).pushReplacementNamed('/SignUp');
            },
            child: Text('Don\'t have an account? Register now',style:TextStyle(color:Colors.white,)))),
        SizedBox(height:15)
    ],)
       
         
      );

  loginHeader() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[    
          SizedBox(
            height: 25.0,
          ),
          Text(
            "Hello",
            style: TextStyle(
                fontWeight: FontWeight.w700, color:Colors.black,fontSize: 28),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "Please login to your account",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );

  loginFields() => Container(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 35.0),
                child: TextFormField(
                  
                  controller: usernameController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the username';
                    }
                    return null;
                  },
                  maxLines: 1,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.mail,size:18,color:Colors.black),
                    hintText: "Enter your username",
                    labelText: "Email Address",
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 35.0),
                child: TextFormField(
                   controller: passwordController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the password';
                    }
                    return null;
                  },
                  maxLines: 1,
                  obscureText: true,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.lock_outline,size:18,color:Colors.black),
                    hintText: "Enter your password",
                    labelText: "Password",
                  ),
                ),
              ),
              Container( 
                padding: EdgeInsets.only(right:50,top:15),
                width: double.infinity,
                child:Text('Forgot Password?',textAlign: TextAlign.right,style:TextStyle(color:Colors.black))
              ),
              SizedBox(
                height: 25.0,
              ),
              Text(error,style:TextStyle(color: Colors.red)),
              Container(
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 80.0),
                width: double.infinity,
                child: RaisedButton(
                  padding: EdgeInsets.all(12.0),
                  shape: StadiumBorder(),
                  child: Text(
                    "LOGIN",
                    style: TextStyle(color: Colors.white),
                  ),
                  color:Colors.redAccent,
                  onPressed: () {
                   navigateService();
                  },
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              // Container(
              //   child: Text('Or Login using social media'),),
              SizedBox(
                height: 15.0,
              ),
              // Container(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [ 
              //       SvgPicture.asset('assets/svg/facebook.svg',width: 25,height:25),
                  
              //     SizedBox(width:20),
              //     SvgPicture.asset('assets/svg/twitter.svg',width:25,height:25),
              //     SizedBox(width:20),
              //     Icon(Icons.mail,size:16),
                  
              //   ],),),
                SizedBox(height:20)
            ],
          ),
        ),
      );
}

