import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class DriverGoogleMapGoHospital extends StatefulWidget {
  const DriverGoogleMapGoHospital(
      {super.key,
      required this.hospitalId,
      required this.bookerLocaitonLat,
      required this.bookerLocaitonLong});
  final String hospitalId;
  final double bookerLocaitonLat;
  final double bookerLocaitonLong;

  @override
  State<DriverGoogleMapGoHospital> createState() => _GoogleMapScreen();
}

class _GoogleMapScreen extends State<DriverGoogleMapGoHospital> {
  final MapController mapController = MapController();
  LocationData? currentLocation;
  List<LatLng> routePointNotPass = [];
  List<LatLng> routePointPassed = [];
  List<Marker> markers = [];
  //location for driver and hospital
  LatLng startPoint = const LatLng(37.42138907886784, -122.08582363492577);
  LatLng endPoint = const LatLng(37.41948907876784, -122.07982363292577);
  final String orsApiKey =
      '5b3ce3597851110001cf62482754ebba865645388e677911173c5159'; // Replace with your OpenRouteService API key
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
          print("aaaaa");
          print(widget.hospitalId);
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
    Timer.periodic(const Duration(seconds: 5), (timer) {
      markers = [];

      _addMarker();
      _getCurrentLocation();
    });
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
        title: const Text('go hospital '),
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
        child: Row(children: <Widget>[
          IconButton(
            tooltip: '-',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {},
          ),
          // But(
          //   tooltip: 'Open navigation menu',
          //   icon: const Icon(Icons.menu),
          //   onPressed: () {},
          // ),
          IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Call',
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            tooltip: '+',
            icon: const Icon(Icons.arrow_back),
            onPressed: () {},
          ),
        ]),
      ),
      // floatingActionButton: const FloatingActionButton(onPressed: null),
    );
  }
}