import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../models/user.dart';
import 'package:google_maps_place_picker/google_maps_place_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProfileSettingsDialog extends StatefulWidget {
  final User user;
  final VoidCallback onChanged;

  ProfileSettingsDialog({Key key, this.user, this.onChanged}) : super(key: key);

  @override
  _ProfileSettingsDialogState createState() => _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState extends State<ProfileSettingsDialog> {
  GlobalKey<FormState> _profileSettingsFormKey = new GlobalKey<FormState>();
  String deliveryAddress = 'pick your delivery address';
  double deliverylat = 0;
  double deliverylng = 0;

  void getdeliveryAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey:
              'AIzaSyB38zgsBuf31H8icWOX5sKQGXXb84JnDhE', // Put YOUR OWN KEY here.
          onPlacePicked: (result) {
            print(result);
            setState(() {
              this.deliveryAddress = result.formattedAddress;
              currentUser.value.address = result.formattedAddress;
              currentUser.value.lat = result.geometry.location.lat.toString();
              currentUser.value.lng = result.geometry.location.lng.toString();
              this.deliverylat = result.geometry.location.lat;
              this.deliverylng = result.geometry.location.lng;
              widget.user.address = result.formattedAddress;
              widget.user.lat = (result.geometry.location.lat).toString();
              widget.user.lng = (result.geometry.location.lng).toString();
            });
            widget.user.address = result.formattedAddress;
            Navigator.of(context).pop();
          },
          initialPosition: LatLng(-33.8567844, 151.213108),
          useCurrentLocation: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                titlePadding:
                    EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                title: Row(
                  children: <Widget>[
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text(
                      S.of(context).profile_settings,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ],
                ),
                children: <Widget>[
                  Form(
                    key: _profileSettingsFormKey,
                    child: Column(
                      children: <Widget>[
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.text,
                          decoration: getInputDecoration(
                              hintText: S.of(context).john_doe,
                              labelText: S.of(context).full_name),
                          initialValue: widget.user.name,
                          validator: (input) => input.trim().length < 3
                              ? S.of(context).not_a_valid_full_name
                              : null,
                          onSaved: (input) => widget.user.name = input,
                        ),
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.emailAddress,
                          decoration: getInputDecoration(
                              hintText: 'johndo@gmail.com',
                              labelText: S.of(context).email_address),
                          initialValue: widget.user.email,
                          onSaved: (input) => widget.user.email = input,
                        ),
                        new TextFormField(
                          style: TextStyle(color: Theme.of(context).hintColor),
                          keyboardType: TextInputType.text,
                          decoration: getInputDecoration(
                              hintText: '+136 269 9765',
                              labelText: S.of(context).phone),
                          initialValue: widget.user.phone,
                          validator: (input) => input.trim().length < 3
                              ? S.of(context).not_a_valid_phone
                              : null,
                          onSaved: (input) => widget.user.phone = input,
                        ),
                        // new TextFormField(
                        //   style: TextStyle(color: Theme.of(context).hintColor),
                        //   keyboardType: TextInputType.text,
                        //   decoration: getInputDecoration(hintText: S.of(context).your_address, labelText: S.of(context).address),
                        //   initialValue: widget.user.address,
                        //   validator: (input) => input.trim().length < 3 ? S.of(context).not_a_valid_address : null,
                        //   onSaved: (input) => widget.user.address = input,
                        // ),
                        GestureDetector(
                            onTap: () {
                              getdeliveryAddress();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              width: MediaQuery.of(context).size.width,
                              child: Card(
                                child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text(this.deliveryAddress)),
                              ),
                            )),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(S.of(context).cancel),
                      ),
                      MaterialButton(
                        onPressed: _submit,
                        child: Text(
                          S.of(context).save,
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.end,
                  ),
                  SizedBox(height: 10),
                ],
              );
            });
      },
      child: Text(
        S.of(context).edit,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }

  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.bodyText2.merge(
            TextStyle(color: Theme.of(context).focusColor),
          ),
      enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).hintColor)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: Theme.of(context).textTheme.bodyText2.merge(
            TextStyle(color: Theme.of(context).hintColor),
          ),
    );
  }

  updateLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("deliverylat", double.parse(currentUser.value.lat));
    prefs.setDouble("deliverylng", double.parse(currentUser.value.lng));
  }

  void _submit() {
    if (_profileSettingsFormKey.currentState.validate()) {
      updateLocation();
      _profileSettingsFormKey.currentState.save();
      widget.onChanged();
      Navigator.pop(context);
    }
  }
}
