import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  final CollectionReference _hospitalCollection =
      FirebaseFirestore.instance.collection('hospital');
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('ambulance');

  String _type = '';
  String _latitude = '';
  String _longitude = '';
  String _plate_number = '';
  int _enable = 0;
  String? _selectedHospital;
  List<Map<String, dynamic>> _hospitals = [];
  // PlaceLocation? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _fetchHospital();
  }

  void _fetchHospital() async {
    try {
      QuerySnapshot querySnapshot = await _hospitalCollection.get();
      setState(() {
        _hospitals = querySnapshot.docs.map((doc) {
          return {'id': doc.id, 'name': doc['name']};
        }).toList();
      });
    } catch (e) {
      print('Error fetching hospitals: $e');
    }
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
        Reference reference = FirebaseStorage.instance.ref().child(
            "image/ambulance/${DateTime.now().microsecondsSinceEpoch}.png");
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

      DocumentReference docRef = await myItems.add({
        'type': _type,
        'latitude': _latitude,
        'longitude': _longitude,
        'plate_number': _plate_number,
        'enable': _enable,
        'hospital_id': _selectedHospital,
        'image': imageUrl ?? 'https://i.pravatar.cc/150',
      });
      await docRef.update({
        'id': docRef.id,
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
                  const SizedBox(height: 16),
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
                  DropdownButtonFormField(
                    isDense: true,
                    hint: const Text('Type'),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(10.0),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'Basic Life Support',
                        child: Text('Basic Life Support'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Advanced Life Support',
                        child: Text('Advanced Life Support'),
                      ),
                    ],
                    onChanged: (val) async {
                      setState(
                        () {
                          _type = val!;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField(
                    isDense: true,
                    hint: const Text('Hospital'),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(10.0),
                    items: _hospitals.map(
                      (val) {
                        return DropdownMenuItem<String>(
                          value: val['id'].toString(),
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
