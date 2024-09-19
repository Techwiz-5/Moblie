import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:techwiz_5/ui/admin/hospital/hospital_screen.dart';
import 'package:techwiz_5/ui/user/home_page.dart';
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
  String _name = '';
  String _address = '';
  String _zipCode = '';
  String _phoneNumber = '';
  int _ambulanceType = 0;
  String? _selectedHospital;
  List<Map<String, dynamic>> _hospitals = [];

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
          return {'id': doc.id, 'name': doc['name']};
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
        'name': _name,
        'address': _address,
        'zipCode': _zipCode,
        'phoneNumber': _phoneNumber,
        'ambulanceType': _ambulanceType,
        'selectedHospital': _selectedHospital,
      });
      await docRef.update({
        'id': docRef.id,
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.toString());
    }
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
                    _name = value!;
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
                DropdownButtonFormField(
                  isDense: true,
                  hint: const Text('Hospital'),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(20.0),
                  items: _hospitals.map(
                    (val) {
                      return DropdownMenuItem<String>(
                        value: val['name'].toString(),
                        child: Text(val['name']),
                      );
                    },
                  ).toList(),
                  onChanged: (val) async {
                    setState(
                      () {
                        _selectedHospital = val;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _createBooking();
                      Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
