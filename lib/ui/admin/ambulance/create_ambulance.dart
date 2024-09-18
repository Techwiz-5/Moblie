import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/models/place.dart';
import 'package:techwiz_5/ui/widgets/location_input.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// import '../widgets/location_input.dart';

class AmbulanceFormScreen extends StatefulWidget {
  const AmbulanceFormScreen({super.key});

  @override
  State<AmbulanceFormScreen> createState() => _AmbulanceFromScreenState();
}

class _AmbulanceFromScreenState extends State<AmbulanceFormScreen> {
  final _formKeyAmbulance = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl;
  File? _pickedImage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('ambulance');

  String _type = '';
  String _latitude = '';
  String _longitude = '';
  String _plate_number = '';
  int _enable = 0;
  // PlaceLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickImage() async {
    try {
      XFile? res = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (res != null) {
        setState(() {
          _pickedImage = File(res.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> _uploadImageToFirebase() async {
    if (_pickedImage != null) {
      try {
        Reference reference = FirebaseStorage.instance
            .ref()
            .child("image/${DateTime.now().microsecondsSinceEpoch}.png");
        await reference.putFile(_pickedImage!).whenComplete(() {
          print('Upload image success');
        });
        imageUrl = await reference.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }

    // try {
    //   String uid = FirebaseAuth.instance.currentUser!.uid;
    //   await _firestore.collection('users').doc(uid).update({
    //     'name': _nameController.text,
    //     'email': _emailController.text,
    //     'image': imageUrl ?? '',
    //   });
    //   setState(() {
    //     isLoading = false;
    //   });
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Profile updated successfully')),
    //   );
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(e.toString())),
    //   );
    // }
  }

  _createAmbulance() async {
    final isValid = _formKeyAmbulance.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKeyAmbulance.currentState!.save();
    try {
      dynamic result = myItems.add({
        'type': _type,
        'latitude': _latitude,
        'longitude': _longitude,
        'plate_number': _plate_number,
        'enable': _enable,
        'image': imageUrl ?? 'https://i.pravatar.cc/150',
      });
      print(result);
      Navigator.pop(context, () {});
    } on FirebaseException catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // title: const Text('Create CV', style: TextStyle(fontWeight: FontWeight.bold),),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: ElevatedButton(
                onPressed: () async {
                  await _uploadImageToFirebase();
                  _createAmbulance();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Create Ambulance'),
              ),
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
                  IconButton(
                      onPressed: () => pickImage(),
                      icon: Icon(Icons.camera_alt)),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: ambulanceFormField('Type'),
                    autocorrect: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill type';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _type = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: ambulanceFormField('Latitude'),
                    autocorrect: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill in latitude';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _latitude = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: ambulanceFormField('Longitude'),
                    autocorrect: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill in longitude';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _longitude = value!;
                    },
                  ),
                  Row(
                    children: [
                      const Text('Enable : '),
                      Row(
                        children: [
                          const Text('Yes'),
                          Radio(
                            value: 0,
                            groupValue: _enable,
                            onChanged: (int? value) {
                              setState(() {
                                _enable = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('No'),
                          Radio(
                            value: 1,
                            groupValue: _enable,
                            onChanged: (int? value) {
                              setState(() {
                                _enable = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: ambulanceFormField('Plate Number'),
                    autocorrect: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill in plate number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _plate_number = value!;
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
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
