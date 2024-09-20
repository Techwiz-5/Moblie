import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:location/location.dart';
import 'package:techwiz_5/ui/user/booking_card_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final CollectionReference myItems = FirebaseFirestore.instance.collection('hospital');
  double latitude = 0.0;
  double longitude = 0.0;
  bool isLoading = true;

  @override
  void initState(){
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    if (mounted) {
      setState(() {
        latitude = lat;
        longitude = lng;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(0.15),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Booking',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : Column(
        children: [
          Flexible(
            child: StreamBuilder(
              stream: myItems.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  final items = streamSnapshot.data!.docs;
                  List outputData = [];
                  for(var i =0; i <items.length; i++) {
                    var object = items[i].data() as Map;
                    object?.putIfAbsent('distance', () => FlutterMapMath().distanceBetween(
                        latitude,
                        longitude,
                        double.parse(items[i]['latitude']),
                        double.parse(items[i]['longitude']),
                        'kilometers'));
                    object?['distance'] = FlutterMapMath().distanceBetween(
                        latitude,
                        longitude,
                        double.parse(items[i]['latitude']),
                        double.parse(items[i]['longitude']),
                        'kilometers') ?? '';
                    outputData.add(object);
                  }
                  outputData.sort((a,b)=>a['distance'].compareTo(b['distance']));
                  outputData.reversed;

                  return ListView.builder(
                    itemCount: outputData.length,
                    itemBuilder: (context, index) {
                      final data = outputData[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          // borderRadius: BorderRadius.circular(20),
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: BookingCardScreen(hospital: data,)
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
