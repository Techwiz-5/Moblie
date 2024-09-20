import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DriverFormScreen extends StatefulWidget {
  const DriverFormScreen({super.key});

  @override
  State<DriverFormScreen> createState() => _DriverFromScreenState();
}

class _DriverFromScreenState extends State<DriverFormScreen> {
  final _formKeyDriver = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl;
  File? _pickedImage;
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('driver');

  String _name = '';
  String _email = '';
  String _phone = '';
  String _password = '';
  String _address = '';

//  'name': _name,
//         'email': _email,
//         'phone': _phone,
//         'address': _address,
//         'password': _password,
//         'role': 'driver',
//         'uid': credential.user!.uid,
//         'image': imageUrl ?? "",
//         'latitude': "",
//         'longitude': "",
//         'enable': 1
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
            .child("image/driver/${DateTime.now().microsecondsSinceEpoch}.png");
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
    final isValid = _formKeyDriver.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKeyDriver.currentState!.save();
    try {
      await _uploadImageToFirebase();

      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      await FirebaseFirestore.instance
          .collection('driver')
          .doc(credential.user!.uid)
          .set({
        'name': _name,
        'email': _email,
        'phone': _phone,
        'address': _address,
        'password': _password,
        'role': 'driver',
        'uid': credential.user!.uid,
        'image': imageUrl ?? "",
        'latitude': "",
        'longitude': "",
        'enable': 1,
        'status': 0
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
                child: const Text('Create Driver'),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKeyDriver,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: driverFormField('Address'),
                    autocorrect: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill address';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _address = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: driverFormField('Email'),
                    autocorrect: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill in email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: driverFormField('Password'),
                    obscureText: true, // Thêm thuộc tính này vào
                    autocorrect: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill in password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: driverFormField('Name'),
                    autocorrect: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill in name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: driverFormField('Phone'),
                    autocorrect: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please fill in plate number';
                      }
                      // Kiểm tra xem giá trị có chỉ chứa số không
                      final numberRegex = RegExp(r'^[0-9]+$');
                      if (!numberRegex.hasMatch(value)) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _phone = value!;
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

  InputDecoration driverFormField(String text) {
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
