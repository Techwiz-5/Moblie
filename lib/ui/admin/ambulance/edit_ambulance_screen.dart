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

class EditAmbulanceScreen extends StatefulWidget {
  const EditAmbulanceScreen({super.key, required this.ambulanceId});
  final String ambulanceId;

  @override
  State<EditAmbulanceScreen> createState() => _EditAmbulanceScreenState();
}

class _EditAmbulanceScreenState extends State<EditAmbulanceScreen> {
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

  Future<DocumentSnapshot> getData() async {
    return await _firestore.collection('ambulance').doc(widget.ambulanceId).get();
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

  Future<void> _deleteOldImageFromFirebase(String oldImageUrl) async {
    try {
      final Reference oldImgRef =
      FirebaseStorage.instance.refFromURL(oldImageUrl);
      await oldImgRef.delete();
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
        if (imageUrl != null && imageUrl!.isNotEmpty) {
          await _deleteOldImageFromFirebase(imageUrl!);
        }
        Reference reference = FirebaseStorage.instance
            .ref()
            .child("image/ambulance/${DateTime.now().microsecondsSinceEpoch}.png");
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
  }

  _createAmbulance() async {
    final isValid = _formKeyAmbulance.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKeyAmbulance.currentState!.save();
    try {
      await _uploadImageToFirebase();

      await _firestore.collection('ambulance').doc(widget.ambulanceId).update({
        'type': _type,
        'latitude': _latitude,
        'longitude': _longitude,
        'plate_number': _plate_number,
        'enable': _enable,
        'image': imageUrl ?? 'https://i.pravatar.cc/150',
      });

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
                  _createAmbulance();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Edit Ambulance'),
              ),
            ),
          ],
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching user data'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User data not found'));
            }
            var ambulanceData = snapshot.data!.data() as Map<String, dynamic>;
            _type = ambulanceData['type'];
            _latitude = ambulanceData['latitude'];
            _longitude = ambulanceData['longitude'];
            _plate_number = ambulanceData['plate_number'];
            _enable = ambulanceData['enable'];
            imageUrl = ambulanceData['image'];
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKeyAmbulance,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _type,
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
                        initialValue: _latitude,
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
                        initialValue: _longitude,
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
                        initialValue: _plate_number,
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
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          image: _pickedImage != null
                              ? DecorationImage(
                            image: FileImage(_pickedImage!),
                            fit: BoxFit.cover,
                          )
                              : (imageUrl != null && imageUrl!.isNotEmpty
                              ? DecorationImage(
                            image: NetworkImage(imageUrl!),
                            fit: BoxFit.cover,
                          )
                              : null),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: imageUrl == null && _pickedImage == null
                            ? const Icon(
                          Icons.image,
                          size: 200,
                          color: Colors.grey,
                        )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            pickImage();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () => pickImage(),
                            icon: Icon(Icons.camera_alt),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
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
