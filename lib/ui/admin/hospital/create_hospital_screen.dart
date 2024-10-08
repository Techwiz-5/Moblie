import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../widgets/MapSearchAndPick.dart';

class HospitalFormScreen extends StatefulWidget {
  const HospitalFormScreen({super.key});

  @override
  State<HospitalFormScreen> createState() => _HospitalFromScreenState();
}

class _HospitalFromScreenState extends State<HospitalFormScreen> {
  final _formKeyCV = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl;
  bool _showError = false;

  File? _pickedImage;
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('hospital');

  String _name = '';
  String _description = '';
  String _address = '';
  String _phone = '';
  double _price = 0;

  LatLng? _selectedLocation;

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
        Reference reference = FirebaseStorage.instance.ref().child(
            "image/hospital/${DateTime.now().microsecondsSinceEpoch}.png");
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

  _createHospital() async {
    if (_selectedLocation == null || _address == null || _address!.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    } else {
      setState(() {
        _showError = false;
      });
      // print('Creating hospital with address: $_address');
      // print('Location: ${_selectedLocation?.latitude}, ${_selectedLocation?.longitude}');
    }
    final isValid = _formKeyCV.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKeyCV.currentState!.save();
    try {
      await _uploadImageToFirebase();
      DocumentReference docRef = await myItems.add({
        'name': _name,
        'description': _description,
        'address': _address,
        'phone': _phone,
        'price': _price,
        'latitude': _selectedLocation!.latitude.toString(),
        'longitude': _selectedLocation!.longitude.toString(),
        'availableSlot': 0,
        'image': imageUrl ?? 'https://i.pravatar.cc/150',
      });
      await docRef.update({
        'id': docRef.id,
      });
      // print(result);
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
          title: const Text('Create Hospital', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
          backgroundColor: const Color(0xff223548),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: ElevatedButton(
                onPressed: () async {
                  _createHospital();
                },
                child: const Text('Create'),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKeyCV,
              child: Column(
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
                  // const SizedBox(height: 16),
                  // TextFormField(
                  //   decoration: cvFormField('Address'),
                  //   autocorrect: true,
                  //   validator: (value) {
                  //     if (value == null || value.trim().isEmpty) {
                  //       return 'Please fill in address';
                  //     }
                  //     return null;
                  //   },
                  //   onSaved: (value) {
                  //     _address = value!;
                  //   },
                  // ),

                  // const SizedBox(height: 16),
                  // LocationInput(onSelectLocation: (location) {
                  //   _selectedLocation = location;
                  // }),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 330, // Specify a height
                    child: MapSearchAndPickWidget(
                      onPicked: (pickedData) {
                        print('===================================');
                        print(pickedData.latLong.latitude);
                        print(pickedData.latLong.longitude);
                        print(pickedData.address);
                        print(pickedData.addressName);
                        print('===================================');
                        setState(() {
                          _selectedLocation = LatLng(
                            pickedData.latLong.latitude,
                            pickedData.latLong.longitude,
                          );
                          _address = pickedData.addressName;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_showError)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Please select a valid location and address before creating.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    minLines: 3,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: _address),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: cvFormField('Description'),
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill in description';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _description = value!;
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
                  TextFormField(
                    decoration: cvFormField('Price'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill in Price';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    onSaved: (value) {
                      _price = double.parse(value!);
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
                      child: Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
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
      fillColor: Colors.white,
      errorStyle: const TextStyle(color: Colors.red),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
