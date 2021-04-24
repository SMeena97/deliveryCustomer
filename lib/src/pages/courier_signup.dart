import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:food_delivery_app/src/models/signup_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}
 
class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
   String error='';
   final emailController = TextEditingController();
    final addressController = TextEditingController();
    final mobileController = TextEditingController();
    final passwordController = TextEditingController();
  
  void navigateService(){

   postProfile(emailController.text, addressController.text,
        mobileController.text, passwordController.text);
   
  }

  Future<SignupModel> postProfile(String email, String address,String mobile, 
      String password) async {
    final http.Response response =
        await http.post(Strings.baseUrl + 'AppUserProfile/addAppUser', body: {
      'app_user_email':email,
      'app_user_password':password
      
    });
    var message;
    try {
    if (response.statusCode == 200 ) {       
    message = SignupModel.fromJson(jsonDecode(response.body)).resultmessage;  
      SnackBar(
        content: Text('Account Created Successfully'),
      );
      Navigator.pushNamed(context, '/courierLogin');
    }
      else { 
          setState(() {
            error= message;
          });        
        }
      return SignupModel.fromJson(jsonDecode(response.body));
    } 
    catch (Exception) {
      throw Exception('Failed to load');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
    child:Scaffold(  
      backgroundColor: Colors.grey,  
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
           FlutterLogo(
            
            size: 60.0,
          ),
          SizedBox(height:10),
          Text("Rexx Technologies",style:TextStyle(color:Colors.white,fontSize: 30)),
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
          child:GestureDetector(
            onTap:(){
            Navigator.pushNamed(context, '/login');
            },
            child: Text('Already have an account? Login now',style:TextStyle(color:Colors.white,)))),
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
            "Create your account",
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
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 35.0),
                child: TextFormField(
                  
                  controller: emailController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter the email';
                    }
                    return null;
                  },
                  maxLines: 1,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.location_city,size:18,color:Colors.yellow),
                    hintText: "Enter your Email",
                    labelText: "Email Address",
                  ),
                ),
              ),
              // Container(
              //   padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 35.0),
              //   child: TextFormField(
              //      controller: addressController,
              //     validator: (value) {
              //       if (value.isEmpty) {
              //         return 'Please enter the address';
              //       }
              //       return null;
              //     },
              //     maxLines: 1,
              //     obscureText: true,
              //     decoration: InputDecoration(
              //       suffixIcon: Icon(Icons.location_city,size:18,color:yellow),
              //       hintText: "Enter your Address",
              //       labelText: "Address",
              //     ),
              //   ),
              // ),
              // Container(
              //   padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 35.0),
              //   child: TextFormField(
              //      controller: mobileController,
              //     validator: (value) {
              //       if (value.isEmpty) {
              //         return 'Please enter the moile';
              //       }
              //       return null;
              //     },
              //     maxLines: 1,
              //     obscureText: true,
              //     decoration: InputDecoration(
              //       suffixIcon: Icon(Icons.call,size:18,color:yellow),
              //       hintText: "Enter your Mobile",
              //       labelText: "Mobile",
              //     ),
              //   ),
              // ),
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
                    suffixIcon: Icon(Icons.lock_outline,size:18,color:Colors.yellow),
                    hintText: "Enter your password",
                    labelText: "Password",
                  ),
                ),
              ),
             
              SizedBox(
                height: 25.0,
              ),
              Text(error,style: TextStyle(color: Colors.red),),
              Container(
                padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 80.0),
                width: double.infinity,
                child: RaisedButton(
                  padding: EdgeInsets.all(12.0),
                  shape: StadiumBorder(),
                  child: Text(
                    "SIGN UP",
                    style: TextStyle(color: Colors.white),
                  ),
                  color:Colors.red,
                  onPressed: () {
                   navigateService();
                  },
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Container(
                child: Text('Or SignUp using social media'),),
              SizedBox(
                height: 15.0,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [ 
                    SvgPicture.asset('assets/svg/facebook.svg',width: 25,height:25),
                  
                  SizedBox(width:20),
                  SvgPicture.asset('assets/svg/twitter.svg',width:25,height:25),
                  SizedBox(width:20),
                  Icon(Icons.mail,size:16),
                  
                ],),),
                SizedBox(height:20)
            ],
          ),
        ),
      );
}

