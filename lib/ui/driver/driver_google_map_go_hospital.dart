import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

import 'driver_page.dart';

class DriverGoogleMapGoHospital extends StatefulWidget {
  const DriverGoogleMapGoHospital(
      {super.key,
      required this.hospitalId,
      required this.bookerLocaitonLat,
      required this.bookerLocaitonLong,
      required this.bookingId});

  final String hospitalId;
  final double bookerLocaitonLat;
  final double bookerLocaitonLong;
  final String bookingId;

  @override
  State<DriverGoogleMapGoHospital> createState() => _GoogleMapScreen();
}

class _GoogleMapScreen extends State<DriverGoogleMapGoHospital> {
  final MapController mapController = MapController();
  LocationData? currentLocation;
  List<LatLng> routePointNotPass = [];
  List<LatLng> routePointPassed = [];
  List<Marker> markers = [];
  String? address;

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
          address = hospitalData['address'] as String?;
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

  @override
  void initState() {
    getData();
    super.initState();
    updateSttus();
    updateBookingStatus();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      markers = [];

      _addMarker();
      _getCurrentLocation();
    });
  }

  Future<void> updateBookingStatus() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    DocumentSnapshot bookingSnapshot =
        await _firestore.collection('booking').doc(widget.bookingId).get();

    if (bookingSnapshot.exists) {
      String bookingId = bookingSnapshot['id'];

      await _firestore.collection('booking').doc(widget.bookingId).update({
        'status': 3,
      });

      print('Booking status updated for booking ID: $bookingId');
    } else {
      print('Booking document does not exist.');
    }
  }

  updateLocation() async {
    try {
      if (currentLocation != null) {
        await FirebaseFirestore.instance
            .collection('booking')
            .doc(widget.bookingId)
            .update({
          'uptLat': currentLocation!.latitude,
          'uptLng': currentLocation!.longitude,
        });
      }
      // Navigator.pop(context, () {});
    } on FirebaseException catch (e) {
      // showSnackBar(context, e.toString());
    }
  }

  updateSttus() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot docSnapshot =
        await _firestore.collection('driver').doc(uid).get();

    if (docSnapshot.exists) {
      await _firestore.collection('driver').doc(uid).update({
        'enable': 2,
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    var location = Location();

    try {
      var userLocation = await location.getLocation();
      setState(() {
        currentLocation = userLocation;
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(userLocation.latitude!, userLocation.longitude!),
            child: const Icon(Icons.location_history,
                color: Color.fromARGB(255, 11, 11, 11), size: 40.0),
          ),
        );
      });
      updateLocation();
    } on Exception {
      currentLocation = null;
    }

    location.onLocationChanged.listen((LocationData newLocation) {
      setState(() {
        currentLocation = newLocation;
      });
    });
  }

  Future<void> _getRouteNotPassed(LatLng destination) async {
    if (currentLocation == null) return;

    final start =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
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
    if (currentLocation == null) return;

    final start =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
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
      'status': 4,
    });

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    String uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot docSnapshot =
        await _firestore.collection('driver').doc(uid).get();

    if (docSnapshot.exists) {
      await _firestore.collection('driver').doc(uid).update({
        'enable': 0,
      });
      print("Document updated successfully.");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DriverPage(driverId: uid),
        ),
      );
    } else {
      print("Document does not exist.");
    }
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
      backgroundColor: const Color.fromARGB(255, 241, 242, 243),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 223, 113, 17),
        title: const Text('Map to Hospital'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            String uid = FirebaseAuth.instance.currentUser!.uid;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DriverPage(driverId: uid),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: currentLocation == null
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
                    currentLocation!.latitude!, currentLocation!.longitude!),
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
          if (currentLocation != null) {
            mapController.move(
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
              15.0,
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        height: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Hospital Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              address != null && address!.isNotEmpty
                  ? address!
                  : 'Address not available',
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  _showMyDialog();
                },
                child: const Text('Finished!'),
              )
            ]),
          ],
        ),
      ),
      // floatingActionButton: const FloatingActionButton(onPressed: null),
    );
  }
}
