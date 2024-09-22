import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:techwiz_5/ui/driver/driver_google_map_go_hospital.dart';
import 'package:techwiz_5/ui/user/user_google_map_go_hospital.dart';

class UserGoogleMapPickupPoint extends StatefulWidget {
  const UserGoogleMapPickupPoint(
      {super.key,
      required this.bookingId,
      required this.driverLocationLat,
      required this.driverLocationLong});
  final String bookingId;
  final double driverLocationLat;
  final double driverLocationLong;
  @override
  State<UserGoogleMapPickupPoint> createState() => _UserGoogleMapScreen();
}

class _UserGoogleMapScreen extends State<UserGoogleMapPickupPoint> {
  final MapController mapController = MapController();
  List<LatLng> routePoints = [];
  List<Marker> markers = [];
  final String orsApiKey =
      '5b3ce3597851110001cf6248ff5c186baf4c4938a8c97e952661a403'; // Replace with your OpenRouteService API key

  void getData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('booking')
          .doc(widget.bookingId)
          .get();
      if (docSnapshot.exists) {
        var bookingData = docSnapshot.data() as Map<String, dynamic>;

        setState(() {
          bookerLocation = LatLng(double.parse(bookingData['latitude']),
              double.parse(bookingData["longitude"]));

          hospitalId = bookingData["hospital_id"];
        });
      } else {
        print('No data found for this booking');
      }
    } catch (e) {
      print('Error fetching booking data: $e');
    }
  }

  String hospitalId = "";
  LatLng bookerLocation = LatLng(0, 0);
  LatLng driverLocation = LatLng(0, 0);

  @override
  void initState() {
    getData();
    super.initState();
    Timer.periodic(Duration(seconds: 10), (timer) {
      driverLocation =
          LatLng(widget.driverLocationLat, widget.driverLocationLong);
      _getCurrentLocation();
      _addDestinationMarker(LatLng(37.41948907876784, -122.07982363292577));
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (this.mounted) {
        setState(() {
          markers.add(
            Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(driverLocation.latitude, driverLocation.longitude),
              child:
                  const Icon(Icons.my_location, color: Colors.blue, size: 40.0),
            ),
          );
        });
      }
    } on Exception {}
  }

  Future<void> _getRoute(LatLng destination) async {
    final start = LatLng(driverLocation.latitude, driverLocation.longitude);
    markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: bookerLocation,
        child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
      ),
    );
    final response = await http.get(
      Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${bookerLocation.longitude},${bookerLocation.latitude}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coords =
          data['features'][0]['geometry']['coordinates'];
      setState(() {
        routePoints =
            coords.map((coord) => LatLng(coord[1], coord[0])).toList();
      });
    } else {
      // Handle errors
      print('Failed to fetch route');
    }
  }

  void _addDestinationMarker(LatLng point) {
    setState(() {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: bookerLocation,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40.0),
        ),
      );
    });
    _getRoute(point);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map to booker'),
      ),
      body: widget.driverLocationLat == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter:
                    LatLng(widget.driverLocationLat, widget.driverLocationLong),
                initialZoom: 15.0,
                // onTap: (tapPosition, point) => _addDestinationMarker(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: markers,
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          mapController.move(
            LatLng(widget.driverLocationLat!, widget.driverLocationLong),
            15.0,
          );
        },
        child: const Icon(Icons.my_location),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserGoogleMapGoHospital(
                          hospitalId: hospitalId,
                          bookerLocaitonLat: bookerLocation.latitude,
                          bookerLocaitonLong: bookerLocation.longitude,
                          bookingId: widget.bookingId,
                          driverLocationLat: widget.driverLocationLat,
                        driverLocationLong: widget.driverLocationLong)
                        ),
              );
            },
            child: const Text('The patient has been picked up'),
          )
        ]),
      ),
      // floatingActionButton: const FloatingActionButton(onPressed: null),
    );
  }
}
