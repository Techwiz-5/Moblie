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
    Timer.periodic(const Duration(seconds: 5), (timer) {
      getCurrentLocation();
    });
    getPolylinepoints();
    super.initState();
  }

  final Completer<GoogleMapController> _controller = Completer();
  Set<Polyline> polylines = {};
  static LatLng sourceLocaion = const LatLng(37.33500926, -122.03272188);
  static LatLng destination = const LatLng(37.33429383, -122.06600055);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then((location) {
      currentLocation = location;
      sourceLocaion = LatLng(location.latitude!, location.longitude!);
    });

    location.onLocationChanged.listen((newLog) {
      currentLocation = newLog;
      GoogleMapController mapController =
          _controller.future as GoogleMapController;

      mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(newLog.latitude!, newLog.longitude!))));

      setState(() {});
    });
    polylinesDraw();
  }

  void getPolylinepoints() async {
    PolylinePoints polyLinePoints = PolylinePoints();
    PolylineResult result = await polyLinePoints.getRouteBetweenCoordinates(
        "AIzaSyAd4rEAQqf58fCJGABqW99teDP9BcuyN08",
        PointLatLng(sourceLocaion.latitude, sourceLocaion.longitude),
        PointLatLng(destination.latitude, destination.longitude));
    // if (result.points.isNotEmpty) {
    result.points.forEach((PointLatLng point) =>
        polylineCoordinates.add(LatLng(point.latitude, point.longitude)));
    setState(() {});
    // }
  }

  polylinesDraw() async {
    polylines.removeWhere((p) => p.polylineId == "draw");
    polylines.add(Polyline(
      polylineId: const PolylineId("draw"),
      visible: true,
      width: 5,
      points: [
        currentLocation != null
            ? LatLng(currentLocation!.latitude!, currentLocation!.longitude!)
            : sourceLocaion,
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
        body: currentLocation == null
            ? const Center(
                child: Text("Loading..."),
              )
            : GoogleMap(
                zoomGesturesEnabled: true,
                initialCameraPosition: CameraPosition(
                    target: currentLocation != null
                        ? LatLng(currentLocation!.latitude!,
                            currentLocation!.longitude!)
                        : sourceLocaion,
                    zoom: 13.5),
                polylines: polylines,
                // polylines: {
                //   Polyline(
                //       polylineId: PolylineId("draw"),
                //       points: polylineCoordinates)
                // },
                mapType: MapType.normal,
                onMapCreated: (mapController) {
//method called when map is created
                  setState(() {
                    _controller.complete(mapController);
                  });
                },
                markers: {
                    currentLocation == null
                        ? Marker(
                            markerId: const MarkerId("sourceLocaion"),
                            position: sourceLocaion
                            // icon: Icons.location_history
                            )
                        : Marker(
                            markerId: const MarkerId("currentLocation"),
                            position: LatLng(currentLocation!.latitude!,
                                currentLocation!.longitude!),
                          ),
                    // Marker(
                    //     markerId: const MarkerId("sourceLocaion"),
                    //     position: sourceLocaion),
                    Marker(
                        markerId: const MarkerId("destination"),
                        position: destination)
                  }));
  }
}
