import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Tripscreen extends StatefulWidget {
  const Tripscreen({Key? key}) : super(key: key);
  @override
  State<Tripscreen> createState() => TripScreenState();
}

class TripScreenState extends State<Tripscreen> {
  @override
  void initState() {
    Timer.periodic(new Duration(seconds: 10), (timer) {
      getCurrentLocation();
      polylinesDraw();
    });

    super.initState();
  }

  final Completer<GoogleMapController> _controller = Completer();
  GoogleMapController? mapController;
  Set<Polyline> polylines = {};
  static LatLng sourceLocaion = LatLng(37.33500926, -122.03272188);
  static LatLng destination = LatLng(37.33429383, -122.06600055);
//   LatLng location1 = const LatLng(28.612898, 77.365930);
// LatLng location2 = const LatLng(28.5897989, 77.3368915);
// LatLng location3 = const LatLng(28.6029172, 77.3195082);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  void getCurrentLocation() {
    setState(() {
      polylines.removeWhere((p) => p.polylineId == "currentLocation");
    });
    Location location = Location();
    location.getLocation().then((location) {
      currentLocation = location;
      sourceLocaion = LatLng(location.latitude!, location.longitude!);
    });

    location.onLocationChanged.listen((newLog) {
      currentLocation = newLog;
    });
  }

  void getPolylinepoints() async {
    PolylinePoints polyLinePoints = PolylinePoints();
    PolylineResult result = await polyLinePoints.getRouteBetweenCoordinates(
        "AIzaSyCKrEqluT4tRUv3YoQ8CGSBG1Zj-vtGJNU",
        PointLatLng(37.33500926, -122.03272188),
        PointLatLng(37.33429383, -122.06600055));
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) =>
          polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
      setState(() {});
    }
  }

  polylinesDraw() async {
    polylines.add(Polyline(
      polylineId: PolylineId(sourceLocaion.toString()),
      visible: true,
      width: 5,
      points: [
        sourceLocaion,
        destination,
      ],
      color: Colors.red,
    ));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Driver"
              // hospital['name'],
              ),
        ),
        body:
            // currentLocation ==null? const Center(child: Text("bbb"),):
            GoogleMap(
                zoomGesturesEnabled: true,
                initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 13.5),
                polylines: polylines,
                mapType: MapType.normal,
                onMapCreated: (controller) {
//method called when map is created
                  setState(() {
                    mapController = controller;
                  });
                },
                markers: {
              currentLocation == null
                  ? Marker(
                      markerId: const MarkerId("sourceLocaion"),
                      position: sourceLocaion)
                  : Marker(
                      markerId: const MarkerId("currentLocation"),
                      position: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!)),
              Marker(
                  markerId: const MarkerId("sourceLocaion"),
                  position: sourceLocaion),
              Marker(
                  markerId: const MarkerId("destination"),
                  position: destination)
            }));
  }
}
