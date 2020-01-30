import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crime Reporter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  static final postLocationUrl = 'http://crime-notify.herokuapp.com/location';
  // final Future<PostLoc>
  Position _currentPosition;
  String _currentAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crime Report"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (_currentPosition != null) ? Text(_currentAddress) : Text('nill'),
            RaisedButton(
              child: Text("HELP"),
              onPressed: () {
                _getCurrentLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      // POST to server
      _sendLocationDetails(position.latitude, position.longitude);
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  _sendLocationDetails(lat, long) async {
    PostLoc post =
        new PostLoc(latitude: lat.toString(), longitude: long.toString());
    await createPostLoc(postLocationUrl, body: post.toMap());
  }
}

class PostLoc {
  final String latitude;
  final String longitude;

  PostLoc({this.latitude, this.longitude});

  factory PostLoc.fromJson(Map<String, dynamic> json) {
    return PostLoc(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    return map;
  }
}

createPostLoc(String url, {Map body}) async {
  return http.post(url, body: body).then((http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    print("Location sent");
  });
}
