import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:location/location.dart';

class BookingCardScreen extends StatefulWidget {
  const BookingCardScreen({super.key, required this.hospital});
  final dynamic hospital;

  @override
  State<BookingCardScreen> createState() => _BookingCardScreenState();
}

class _BookingCardScreenState extends State<BookingCardScreen> {
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    getUserCurrentLocation();
  }

  Future<void> getUserCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _showNormalConfirmationDialog(
          'Location Is Disabled',
          'App wants to access your location',
          'Enable Location',
          () {
            AppSettings.openAppSettings();
          },
        );
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _showNormalConfirmationDialog(
          'Location Permission Denied',
          'Please go to settings and enable location permission',
          'Open Settings',
          () {
            AppSettings.openAppSettings();
          },
        );
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        latitude = currentLocation.latitude!;
        longitude = currentLocation.longitude!;
      });
    });
  }

  void _showNormalConfirmationDialog(
      String title, String message, String buttonText, VoidCallback onPressed) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String distanceKm(double lat, double lng) {
    double result = FlutterMapMath()
        .distanceBetween(latitude, longitude, lat, lng, 'kilometers');
    return '${result.toStringAsFixed(2)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: const Border(
            left: BorderSide(
              //                   <--- left side
              color: Colors.blue,
              width: 6.0,
            ),
            top: BorderSide(
              //                    <--- top side
              color: Colors.blue,
              width: 1.0,
            ),
            right: BorderSide(
              //                    <--- top side
              color: Colors.blue,
              width: 1.0,
            ),
            bottom: BorderSide(
              //                    <--- top side
              color: Colors.blue,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Center(
                child: Stack(
              alignment: Alignment.bottomLeft,
              children: <Widget>[
                Image.network(
                  widget.hospital['image'],
                  width: double.infinity,
                  height: 205,
                  fit: BoxFit.cover,
                ),
              ],
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 40,
                      child: Text(
                        widget.hospital['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: Text(
                        distanceKm(double.parse(widget.hospital['latitude']),
                            double.parse(widget.hospital['longitude'])),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.hospital['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => FlutterPhoneDirectCaller.callNumber(
                        widget.hospital['phone']),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Call now ",
                          style: TextStyle(color: Colors.white),
                        ),
                        Icon(
                          Icons.call,
                          color: Colors.white,
                        )
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
