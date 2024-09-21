import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:techwiz_5/ui/admin/hospital/hospital_screen.dart';
import 'package:techwiz_5/ui/user/home_page.dart';
import 'package:techwiz_5/ui/widgets/hospital_card.dart';
import 'package:techwiz_5/ui/widgets/location_input.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final CollectionReference _hospitalsCollection =
      FirebaseFirestore.instance.collection('hospital');
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('booking');
  final _formKeyAmbulance = GlobalKey<FormState>();
  String _namePatient = '';
  String _address = '';
  String _zipCode = '';
  String _phoneNumber = '';
  int _ambulanceType = 0;
  String? _selectedHospital;
  List<Map<String, dynamic>> _hospitals = [];
  DateTime? selectedDate;
  LatLng? _selectedLocation;
  String selectHospitalId = '';

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  void _fetchHospitals() async {
    try {
      QuerySnapshot querySnapshot = await _hospitalsCollection.get();
      setState(() {
        _hospitals = querySnapshot.docs.map((doc) {
          return {'id': doc.id, 'name': doc['name'], 'image': doc['image'], 'address': doc['address']};
        }).toList();
      });
    } catch (e) {
      print('Error fetching hospitals: $e');
    }
  }

  _createBooking() async {
    final isValid = _formKeyAmbulance.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKeyAmbulance.currentState!.save();
    try {
      DocumentReference docRef = await myItems.add({
        'name_patient': _namePatient,
        'address': _address,
        'zip_code': _zipCode,
        'phone_number': _phoneNumber,
        'ambulance_id': '',
        'ambulance_type': _ambulanceType,
        'hospital_id': selectHospitalId,
        'status': 0,
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'urgent': 0,
        'create_at': DateTime.now(),
        'booking_time': selectedDate,
        'driver_id': '',
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      });
      await docRef.update({
        'id': docRef.id,
      });
      await sendNotificationToDrivers(docRef.id);
    } on FirebaseException catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> sendNotificationToDrivers(String bookingId) async {
    await FirebaseMessaging.instance.subscribeToTopic('allDrivers');

    await FirebaseMessaging.instance.sendMessage(
      to: '/topics/allDrivers',
      data: {
        'title': 'New Ride Request',
        'body': 'A user has requested a ride.',
        'bookingId': bookingId,
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          "Booking",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKeyAmbulance,
            child: Column(
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  decoration: ambulanceFormField('Patient name'),
                  autocorrect: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please fill type';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _namePatient = value!;
                  },
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ambulance type : '),
                    Row(
                      children: [
                        const Text('Basic Life Support'),
                        Radio(
                          value: 0,
                          groupValue: _ambulanceType,
                          onChanged: (int? value) {
                            setState(() {
                              _ambulanceType = value!;
                            });
                          },
                        ),
                        const Text('Advanced Life Support'),
                        Radio(
                          value: 1,
                          groupValue: _ambulanceType,
                          onChanged: (int? value) {
                            setState(() {
                              _ambulanceType = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: ambulanceFormField('Phone Number'),
                  autocorrect: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please fill in phone number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _phoneNumber = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: ambulanceFormField('Address'),
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
                  decoration: ambulanceFormField('Zip code'),
                  autocorrect: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please fill in address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _zipCode = value!;
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                                      height: MediaQuery.of(context).size.height *
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
                                                  'Please choose one Hospital to book',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                      FontWeight.bold),
                                                ),
                                              )),
                                          Positioned(
                                              child: _hospitals.isEmpty
                                                  ? Container(
                                                  height: 110,
                                                  alignment: Alignment.center,
                                                  child: const Text(
                                                      'You still not create any CV'))
                                                  : Container(
                                                margin:
                                                const EdgeInsets.only(
                                                    top: 50),
                                                // padding: const EdgeInsets.all(8),
                                                height: 700,
                                                child:
                                                SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      ListView.builder(
                                                        physics:
                                                        const ClampingScrollPhysics(),
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                        Axis.vertical,
                                                        itemCount:
                                                        _hospitals
                                                            .length,
                                                        itemBuilder: (BuildContext
                                                        context,
                                                            int index) =>
                                                            RadioListTile(
                                                              title: HospitalCard(hospital: _hospitals[index],),
                                                              value: _hospitals[
                                                              index]
                                                              ['id']
                                                                  .toString(),
                                                              groupValue:
                                                              selectHospitalId,
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  selectHospitalId =
                                                                  value!;
                                                                });
                                                              },
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )),
                                          Positioned.fill(
                                              bottom: 10,
                                              child: Align(
                                                alignment: Alignment.bottomCenter,
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            child: const Text(
                                                                'Select'),
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
                    child: const Text('Select Hospital'),
                  ),
                ),
                SizedBox(height: 20.0),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Colors.black)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedDate == null
                              ? 'Select date'
                              : '${selectedDate?.day.toString()}-${selectedDate?.month.toString()}-${selectedDate?.year.toString()}',
                        ),
                        const Icon(Icons.calendar_month_outlined)
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LocationInput(onSelectLocation: (location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                }),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _createBooking();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Booking'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration ambulanceFormField(String text) {
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
      fillColor: Colors.white,
      errorStyle: const TextStyle(color: Colors.red),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
