import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/models/place.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/location_input.dart';

class HospitalFormScreen extends StatefulWidget {
  const HospitalFormScreen({super.key});

  @override
  State<HospitalFormScreen> createState() => _HospitalFromScreenState();
}

class _HospitalFromScreenState extends State<HospitalFormScreen> {
  final _formKeyCV = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl;
  File? _pickedImage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference myItems = FirebaseFirestore.instance.collection('hospital');

  String _name = '';
  String _description = '';
  String _address = '';
  String _phone = '';
  PlaceLocation? _selectedLocation;

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

  _createHospital() async {
    final isValid = _formKeyCV.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKeyCV.currentState!.save();
    try{
      dynamic result = myItems.add({
        'name': _name,
        'description': _description,
        'address': _address,
        'phone': _phone,
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
                  _createHospital();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Create CV'),
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
                  IconButton(onPressed: () => pickImage(), icon: Icon(Icons.camera_alt)),
                  const SizedBox(height: 16),
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
                  LocationInput(onSelectLocation: (location) {
                    _selectedLocation = location;
                  })
                ],
              ),
            ),
          ),
        ));
  }

  InputDecoration cvFormField (String text){
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
