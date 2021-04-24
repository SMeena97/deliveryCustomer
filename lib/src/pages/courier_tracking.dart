import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:food_delivery_app/src/constants/strings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../repository/user_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:food_delivery_app/src/repository/api_manager.dart';

double sourceLat;
double sourceLng;
// double destinationLat=10.822689940582878;
// double destinationLng=78.6832230216593;

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
LatLng SOURCE_LOCATION;

LatLng DEST_LOCATION;

class CourierMapPage extends StatefulWidget {
  final String deliveryboyid;
  final String courierid;
  final String destinationLat;
  final String destinationLng;
  CourierMapPage({Key key, @required this.deliveryboyid, this.courierid,this.destinationLat,this.destinationLng})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => CourierMapPageState();
}

class CourierMapPageState extends State<CourierMapPage> {
  Timer _timer;
  bool isLoading = true;
  Position _currentPosition=Position(
    longitude: 0.0,latitude: 0.0
  );
  Position _getPosition;
  Completer<GoogleMapController> _controller = Completer();

  // this set will hold my markers
  Set<Marker> _markers = {};

  // this will hold the generated polylines
  Set<Polyline> _polylines = {};

  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];

  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey;

  // for my custom icons
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  CameraPosition initialLocation;

  Future<void> getDeliveryboyLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map data;
    print("deliveryboyId" + {widget.deliveryboyid}.toString());
    print("app_user_id" + {prefs.getString("id")}.toString());
    print("courierid" + {widget.courierid}.toString());
    final response = await http.get(Strings.baseUrl +
        'Profile/loadDeliveryboyLocation?deliveryboyid=${widget.deliveryboyid}&app_user_id=${prefs.getString("id")}&courierid=${widget.courierid}');
      data = jsonDecode(response.body);
    if (data["resultcode"]=='200') {
      // print(LoginModel.fromJson(jsonDecode(response.body)));
      print('map res');
      print(response.body);
        setState(() {
          sourceLat = double.parse(data["result"]["del_boy_lat"]);
          sourceLng = double.parse(data["result"]["del_boy_lng"]);
          SOURCE_LOCATION = LatLng(sourceLat, sourceLng);
          isLoading = false;
         
        });
         if (!isLoading) {
            initialLocation = CameraPosition(
                zoom: CAMERA_ZOOM,
                bearing: CAMERA_BEARING,
                tilt: CAMERA_TILT,
                target: SOURCE_LOCATION);
          }      
      print(sourceLat);
      print(sourceLng);
    } else {
      throw Exception('Failed to load');
    }
  }
    _refresh() {

    const fiveSeconds = const Duration(seconds: 1);
    _timer=Timer.periodic(
        fiveSeconds, (Timer t) => getDeliveryboyLocation());  
}
 getMapKey()async{
    Future<String> key;
    key=API_Manager().getGoogleMapApiKey();  
    key.then((obj){
    setState(() {
      this.googleAPIKey=obj;
    });
   
    });
}
  @override
  void initState() {
    getMapKey();
   _refresh(); 
    setSourceAndDestinationIcons();
     super.initState();
  }
   @override
  void dispose() {
   _timer.cancel();
    super.dispose();
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/driving_pin.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/destination_map_marker.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Tracking'),
        ),
        body: isLoading
            ? Container(
                color: Colors.transparent,
                child: Center(child: CircularProgressIndicator()),
              )
            : GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: false,
                markers: _markers,
                polylines: _polylines,
                mapType: MapType.normal,
                initialCameraPosition: isLoading
                    ? CameraPosition(
                        zoom: CAMERA_ZOOM,
                        bearing: CAMERA_BEARING,
                        tilt: CAMERA_TILT,
                        target: LatLng(0.0, 0.0))
                    : initialLocation,
                onMapCreated: onMapCreated));
  }

  void onMapCreatedInital(GoogleMapController controller) {
    controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    /*  setMapPins();
    setPolylines();*/
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    /*_currentPosition=  await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(_currentPosition);*/
    setMapPins();
    setPolylines();
  }

  void setMapPins() async{
    DEST_LOCATION =
        LatLng(double.parse(widget.destinationLat),double.parse(widget.destinationLng));

    setState(() {
      // source pin
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: SOURCE_LOCATION,
          icon: sourceIcon));
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: DEST_LOCATION,
          icon: destinationIcon));
    });
  }

  setPolylines() async {
    List<PointLatLng> result = await polylinePoints?.getRouteBetweenCoordinates(
        googleAPIKey,
        SOURCE_LOCATION.latitude,
        SOURCE_LOCATION.longitude,
        double.parse(widget.destinationLat),
        double.parse(widget.destinationLng));
    if (result.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
           width: 2,
          polylineId: PolylineId("poly"),
          color: Color.fromARGB(255, 40, 122, 198),
          points: polylineCoordinates);

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.add(polyline);
    });
  }


  /*_getCurrentLocation() async{
    _currentPosition=  await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

     // _currentPosition=_getPosition;
      print(_currentPosition);

  }*/
}

class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}