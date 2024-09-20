import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/models/place.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../widgets/location_input.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.hospitalId});
  final String hospitalId;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreen();
}

class _EditProfileScreen extends State<EditProfileScreen> {
  final _formKeyCV = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl;
  File? _pickedImage;
  final CollectionReference myItems =
  FirebaseFirestore.instance.collection('account');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _name = '';
  late String _address;
  late String _email;
  late String _phone;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      DocumentSnapshot docSnapshot =
      await _firestore.collection('account').doc(widget.hospitalId).get();
      if (docSnapshot.exists) {
        var accountData = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _name = accountData['name'];
          _email = accountData['email'];
          _address = accountData['address'];
          _phone = accountData['phone'];
          accountData['image'] != null ? imageUrl = accountData['image'] : null;
        });
      } else {
        print('No data found for this account');
      }
    } catch (e) {
      print('Error fetching account data: $e');
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
        Reference reference = FirebaseStorage.instance.ref().child(
            "image/user/${DateTime.now().microsecondsSinceEpoch}.png");
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

  _editHospital() async {
    final isValid = _formKeyCV.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKeyCV.currentState!.save();
    try {
      await _uploadImageToFirebase();
      await _firestore.collection('account').doc(FirebaseAuth.instance.currentUser!.uid).update({
        'name': _name,
        'email': _email,
        'address': _address,
        'phone': _phone,
        'image': imageUrl,
      });
      Navigator.pop(context, true);
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
      ),
      body: (_name.isEmpty)
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKeyCV,
            child: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (imageUrl != null && imageUrl!.isNotEmpty
                            ? NetworkImage(imageUrl!)
                            : null) as ImageProvider?,
                        child: imageUrl == null && _pickedImage == null
                            ? const Icon(
                          Icons.person,
                          size: 200,
                          color: Colors.grey,
                        )
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 130,
                      top: 7,
                      child: GestureDetector(
                        onTap: () {
                          pickImage();
                        },
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _name,
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
                  initialValue: _address,
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
                  initialValue: _email,
                  decoration: cvFormField('Address'),
                  autocorrect: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please fill in address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _email = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _phone,
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
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      _editHospital();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
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
      fillColor: Colors.white,
      errorStyle: const TextStyle(color: Colors.red),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
