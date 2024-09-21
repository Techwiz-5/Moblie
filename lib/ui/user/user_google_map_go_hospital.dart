import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class UserGoogleMapGoHospital extends StatefulWidget {
  const UserGoogleMapGoHospital(
      {super.key,
      required this.hospitalId,
      required this.bookerLocaitonLat,
      required this.bookerLocaitonLong,
      required this.bookingId,
      required this.driverLocationLat,
      required this.driverLocationLong});
  final String hospitalId;
  final double bookerLocaitonLat;
  final double bookerLocaitonLong;
  final String bookingId;
  final double driverLocationLat;
  final double driverLocationLong;

  @override
  State<UserGoogleMapGoHospital> createState() => _UserGoogleMapScreen();
}

class _UserGoogleMapScreen extends State<UserGoogleMapGoHospital> {
  final MapController mapController = MapController();
  LocationData? currentLocation;
  List<LatLng> routePointNotPass = [];
  List<LatLng> routePointPassed = [];
  List<Marker> markers = [];
  //location for driver and hospital
  // LatLng startPoint = const LatLng(37.42138907886784, -122.08582363492577);
  // LatLng endPoint = const LatLng(37.41948907876784, -122.07982363292577);
  final String orsApiKey =
      '5b3ce3597851110001cf6248ff5c186baf4c4938a8c97e952661a403'; // Replace with your OpenRouteService API key
  void getData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('hospital')
          .doc(widget.hospitalId)
          .get();
      if (docSnapshot.exists) {
        var hospitalData = docSnapshot.data() as Map<String, dynamic>;

        setState(() {
          hospitalLocation = LatLng(double.parse(hospitalData['latitude']),
              double.parse(hospitalData["longitude"]));
          // hospitalId = hospitalData["hospital_id"].to;
        });
      } else {
        print('No data found for this booking');
      }
    } catch (e) {
      print('Error fetching booking data: $e');
    }
  }

  LatLng hospitalLocation = LatLng(0, 0);
  LatLng driverLocation = LatLng(0, 0);

  @override
  void initState() {
    getData();
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      markers = [];

      _addMarker();
      driverLocation =
          LatLng(widget.driverLocationLat, widget.driverLocationLong);
      _getCurrentLocation();
    });
  }

  // updateLocation() async {
  //   try {
  //     if (currentLocation != null) {
  //       await FirebaseFirestore.instance
  //           .collection('booking')
  //           .doc(widget.bookingId)
  //           .update({
  //         'uptLat': currentLocation!.latitude,
  //         'uptLng': currentLocation!.longitude,
  //       });
  //     }
  //     // Navigator.pop(context, () {});
  //   } on FirebaseException catch (e) {
  //     // showSnackBar(context, e.toString());
  //   }
  // }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(driverLocation.latitude, driverLocation.longitude),
            child: const Icon(Icons.location_history,
                color: Color.fromARGB(255, 11, 11, 11), size: 40.0),
          ),
        );
      });
      // updateLocation();
    } on Exception {}
  }

  Future<void> _getRouteNotPassed(LatLng destination) async {
    final start = LatLng(driverLocation.latitude, driverLocation.longitude);
    final response = await http.get(
      Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${destination.longitude},${destination.latitude}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coords =
          data['features'][0]['geometry']['coordinates'];
      setState(() {
        routePointNotPass =
            coords.map((coord) => LatLng(coord[1], coord[0])).toList();
      });
    } else {}
  }

  Future<void> _getRoutePassed(LatLng startPoint) async {
    final start = LatLng(driverLocation.latitude, driverLocation.longitude);
    final response = await http.get(
      Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${startPoint.longitude},${startPoint.latitude}&end=${start.longitude},${start.latitude}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coords =
          data['features'][0]['geometry']['coordinates'];
      setState(() {
        routePointPassed =
            coords.map((coord) => LatLng(coord[1], coord[0])).toList();
        // markers.add(
        //   Marker(
        //     width: 80.0,
        //     height: 80.0,
        //     point: startPoint,
        //     child: const Icon(Icons.location_on,
        //         color: Color.fromARGB(255, 9, 4, 3), size: 40.0),
        //   ),
        // );
      });
    } else {}
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to take this booking??'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                // receiveBooking();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Receive'),
              onPressed: () {
                receiveBooking();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void receiveBooking() async {
    await FirebaseFirestore.instance
        .collection('booking')
        .doc(widget.bookingId)
        .update({
      'status': 2,
    });
  }

  void _addMarker() {
    setState(() {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: LatLng(widget.bookerLocaitonLat, widget.bookerLocaitonLong),
          child: const Icon(Icons.location_on,
              color: Color.fromARGB(255, 27, 188, 220), size: 40.0),
        ),
      );
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: hospitalLocation,
          child: const Icon(Icons.local_hospital_outlined,
              color: Colors.red, size: 40.0),
        ),
      );
    });
    _getRouteNotPassed(hospitalLocation);
    _getRoutePassed(
        LatLng(widget.bookerLocaitonLat, widget.bookerLocaitonLong));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map to Hospital'),
      ),
      body: widget.driverLocationLat == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: mapController,
              options: MapOptions(
                interactionOptions: const InteractionOptions(
                  enableMultiFingerGestureRace: true,
                  flags: InteractiveFlag.doubleTapDragZoom |
                      InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.flingAnimation |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.scrollWheelZoom,
                ),
                initialCenter: LatLng(
                    widget.driverLocationLat, widget.driverLocationLong!),
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
                      points: routePointNotPass,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                    Polyline(
                      points: routePointPassed,
                      strokeWidth: 4.0,
                      color: const Color.fromARGB(255, 81, 83, 84),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.driverLocationLat != null) {
            mapController.move(
              LatLng(widget.driverLocationLat, widget.driverLocationLong),
              15.0,
            );
          }
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
              _showMyDialog();
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => DriverGoogleMapGoHospital(
              //             hospitalId: hospitalId,
              //             bookerLocaitonLat: bookerLocation.latitude,
              //             bookerLocaitonLong: bookerLocation.longitude,
              //           )),
              // );
            },
            child: const Text('finished!'),
          )
        ]),
      ),
      // floatingActionButton: const FloatingActionButton(onPressed: null),
    );
  }
}
