import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:techwiz_5/ui/widgets/location_input.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';

class BookingCardScreen extends StatefulWidget {
  const BookingCardScreen({super.key, required this.hospital});
  final dynamic hospital;

  @override
  State<BookingCardScreen> createState() => _BookingCardScreenState();
}

class _BookingCardScreenState extends State<BookingCardScreen> {
  final _formKeyBooking = GlobalKey<FormState>();
  final CollectionReference myItems =
  FirebaseFirestore.instance.collection('booking');
  double latitude = 0.0;
  double longitude = 0.0;
  late Location _location;
  late Stream<LocationData> _locationStream;
  bool _isListening = false;
  String _name = '';
  String _address = '';
  String _phone = '';
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _location = Location();
    getUserCurrentLocation();
  }

  Future<void> getUserCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
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

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
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

    // Start listening to location changes
    _locationStream = _location.onLocationChanged;
    _locationStream.listen((LocationData currentLocation) {
      if (!mounted) return;
      // Update state only if the location has changed significantly
      if ((latitude - currentLocation.latitude!).abs() > 0.001 ||
          (longitude - currentLocation.longitude!).abs() > 0.001) {
        setState(() {
          latitude = currentLocation.latitude!;
          longitude = currentLocation.longitude!;
        });
      }
    });
    _isListening = true;
  }

  @override
  void dispose() {
    if (_isListening) {
      _locationStream.drain();
    }
    super.dispose();
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

  _createBookingUrgent() async {
    final isValid = _formKeyBooking.currentState!.validate();
    if (!isValid) {
      return;
    }

    if (_selectedLocation == null) {
      showSnackBar(context, 'Please select a location');
      return;
    }

    _formKeyBooking.currentState!.save();
    try {
      DocumentReference docRef = await myItems.add({
        'name_patient': _name,
        'address': _address,
        'phone_number': _phone,
        'ambulance_id': '',
        // 'ambulance_type': _ambulanceType,
        'hospital_id': widget.hospital['id'],
        'status': 0,
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'urgent': 1,
        'create_at': DateTime.now(),
        'booking_time': DateTime.now(),
        'driver_id': '',
        'latitude': _selectedLocation!.latitude.toString(),
        'longitude': _selectedLocation!.longitude.toString(),
      });
      await docRef.update({
        'id': docRef.id,
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.toString());
    }
  }


  Future<void> _makePhoneCall() async {
    await FlutterPhoneDirectCaller.callNumber(widget.hospital['phone']);
    if (mounted) {
      Navigator.of(context).pop();
    }
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red
                    ),
                    onPressed: () async {
                      showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, setState) =>
                                  Container(
                                      width: double.infinity,
                                      height:
                                      MediaQuery.of(context).size.height *
                                          0.85,
                                      color: Colors.white,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                              top: 0,
                                              child: Container(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 16),
                                                child: const Text(
                                                  'Form',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              )),
                                          Positioned(
                                              child: Container(
                                                margin:
                                                const EdgeInsets.only(
                                                    top: 50),
                                                padding: const EdgeInsets.all(12),
                                                height: 700,
                                                child:
                                                SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      Form(
                                                        key: _formKeyBooking,
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            TextFormField(
                                                              decoration: cvFormField('Name'),
                                                              autocorrect: true,
                                                              validator: (value) {
                                                                if (value == null || value.trim().isEmpty) {
                                                                  return 'Please fill name';
                                                                }
                                                                return null;
                                                              },
                                                              onSaved: (value) {
                                                                _name = value!;
                                                              },
                                                            ),
                                                            const SizedBox(height: 16),
                                                            TextFormField(
                                                              decoration: cvFormField('Address'),
                                                              autocorrect: true,
                                                              validator: (value) {
                                                                if (value == null || value.trim().isEmpty) {
                                                                  return 'Please fill in address';
                                                                }
                                                                return null;
                                                              },
                                                              onSaved: (value) {
                                                                _address = value!;
                                                              },
                                                            ),
                                                            const SizedBox(height: 16),
                                                            TextFormField(
                                                              decoration: cvFormField('Phone number'),
                                                              validator: (value) {
                                                                if (value == null || value.trim().isEmpty) {
                                                                  return 'Please fill in phone number';
                                                                }
                                                                return null;
                                                              },
                                                              keyboardType: TextInputType.phone,
                                                              onSaved: (value) {
                                                                _phone = value!;
                                                              },
                                                            ),
                                                            const SizedBox(height: 16),
                                                            LocationInput(
                                                              onSelectLocation: (location) {
                                                                _selectedLocation = location;
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )),
                                          Positioned.fill(
                                              bottom: 10,
                                              child: Align(
                                                alignment:
                                                Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          child: ElevatedButton(
                                                            onPressed: () async {
                                                              await _createBookingUrgent();
                                                              _makePhoneCall();
                                                            },
                                                            child: const Text(
                                                                'Submit and Call'),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ))
                                        ],
                                      )),
                            );
                          });
                    },
                    child: const Text('Call', style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  InputDecoration cvFormField(String text) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          const Text('*', style: TextStyle(color: Colors.red)),
        ],
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      errorStyle: const TextStyle(color: Colors.red),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
