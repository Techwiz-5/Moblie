import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({super.key, required this.hospital});
  final dynamic hospital;


  String get locationImage {
    final lat = hospital['latitude'];
    final lng = hospital['longitude'];
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyCKrEqluT4tRUv3YoQ8CGSBG1Zj-vtGJNU';
  }

  @override
  Widget build(BuildContext context) {
    LatLng? _pickedLocation;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          hospital['name'],
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            // onTap: ,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                double.parse(hospital['latitude']),
                double.parse(hospital['longitude']),
              ),
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('m1'),
                position: _pickedLocation ?? LatLng(
                  double.parse(hospital['latitude']),
                  double.parse(hospital['longitude']),
                ),
              )
            },
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
