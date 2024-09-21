import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:techwiz_5/ui/admin/hospital/hospital_screen.dart';
import 'package:techwiz_5/ui/user/home_page.dart';
import 'package:techwiz_5/ui/widgets/hospital_card.dart';
import 'package:techwiz_5/ui/widgets/location_input.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';

import 'hospital_select_card.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  double latitude = 0.0;
  double longitude = 0.0;
  bool isLoading = true;
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
  List<Map<String, dynamic>> _hospitals = [];
  DateTime? selectedDate;
  LatLng? _selectedLocation;
  dynamic selectHospital;

  @override
  void initState() {
    super.initState();
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
        'hospital_id': selectHospital['id'],
        'status': 0,
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'urgent': 0,
        'create_at': DateTime.now(),
        'booking_time': selectedDate,
        'driver_id': '',
        'latitude': _selectedLocation!.latitude.toString(),
        'longitude': _selectedLocation!.longitude.toString(),
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
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  onGoBack() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Booking",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () async {
              await _createBooking();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomeScreen()));
            },
            child: const Text('Create Booking'),
          ),
        ],
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
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
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
                const Text('Select location'),
                LocationInput(onSelectLocation: (location) {
                  setState(() {
                    _selectedLocation = location;
                  });
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if(_selectedLocation == null) {
                        showSnackBar(context, 'Please select location first');
                        return;
                      }
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
                            return Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.9,
                              child: Scaffold(
                                appBar: AppBar(
                                  title: const Text('Select Hospital'),
                                  centerTitle: true,
                                ),
                                body: Column(
                                  children: [
                                    Flexible(
                                      child: StreamBuilder(
                                        stream: _hospitalsCollection.snapshots(),
                                        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                                          var isLoading2 = true;
                                          if (streamSnapshot.hasData) {
                                            final dataList = streamSnapshot.data!.docs;
                                            List outputData = [];
                                            for(var i =0; i <dataList.length; i++) {
                                              var object = dataList[i].data() as Map;
                                              object.putIfAbsent('distance', () => FlutterMapMath().distanceBetween(
                                                  _selectedLocation!.latitude,
                                                  _selectedLocation!.longitude,
                                                  double.parse(dataList[i]['latitude']),
                                                  double.parse(dataList[i]['longitude']),
                                                  'kilometers'));
                                              object['distance'] = FlutterMapMath().distanceBetween(
                                                  _selectedLocation!.latitude,
                                                  _selectedLocation!.longitude,
                                                  double.parse(dataList[i]['latitude']),
                                                  double.parse(dataList[i]['longitude']),
                                                  'kilometers');
                                              outputData.add(object);
                                            }
                                            outputData.sort((a,b)=>a['distance'].compareTo(b['distance']));
                                            outputData.reversed;

                                            return StatefulBuilder(
                                                builder: (BuildContext context, setState) {
                                                  if(outputData.isNotEmpty){
                                                    setState((){
                                                      isLoading2 = false;
                                                    });
                                                  }

                                                  print(_selectedLocation!.latitude);
                                                  return isLoading2 ? CircularProgressIndicator() : SingleChildScrollView(
                                                    child: ListView.builder(
                                                      physics: const ClampingScrollPhysics(),
                                                      shrinkWrap: true,
                                                      scrollDirection: Axis.vertical,
                                                      itemCount: outputData.length,
                                                      itemBuilder: (context, index) {
                                                        final data = outputData[index];
                                                        return RadioListTile(
                                                          selectedTileColor: Colors.blue,
                                                          title: HospitalSelectCard(
                                                            hospital: data,
                                                            color: selectHospital != null && data['id'] == selectHospital['id'] ? Colors.blue.shade50: Colors.white,),
                                                          value: data,
                                                          groupValue: selectHospital,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectHospital = value!;
                                                            });
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }
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
                                bottomNavigationBar: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white
                                    ),
                                    child: const Text('Select'),
                                  ),
                                ),
                              ),
                            );
                          }).whenComplete(onGoBack);
                    },
                    child: Text(selectHospital != null ? selectHospital['name'] : 'Select Hospital'),
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
