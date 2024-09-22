import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({super.key, required this.hospital});
  final dynamic hospital;

  String get locationImage {
    final lat = hospital['latitude'];
    final lng = hospital['longitude'];
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyCOaEIViy3KsNPhxg8Nfd9RaD_rVzzDsow';
  }

  @override
  Widget build(BuildContext context) {
    LatLng? _pickedLocation;
    return Scaffold(
      appBar: AppBar(
        title: Text('${hospital['name']}',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          ),),
        backgroundColor: const Color(0xff223548),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xff475e75),
      body: Stack(
        children: [
          // GoogleMap(
          //   initialCameraPosition: CameraPosition(
          //     target: LatLng(
          //       double.parse(hospital['latitude']),
          //       double.parse(hospital['longitude']),
          //     ),
          //     zoom: 16,
          //   ),
          //   markers: {
          //     Marker(
          //       markerId: const MarkerId('m1'),
          //       position: _pickedLocation ?? LatLng(
          //         double.parse(hospital['latitude']),
          //         double.parse(hospital['longitude']),
          //       ),
          //     )
          //   },
          // ),
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                double.parse(hospital['latitude']),
                double.parse(hospital['longitude']),
              ),
              initialZoom: 17.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: LatLng(
                      double.parse(hospital['latitude']),
                      double.parse(hospital['longitude']),
                    ),
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 40.0),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(hospital['image']),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    hospital['address'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22
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
