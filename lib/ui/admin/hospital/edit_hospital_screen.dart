import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:techwiz_5/models/place.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../widgets/location_input.dart';

class EditHospitalScreen extends StatefulWidget {
  const EditHospitalScreen({super.key, required this.hospitalId});
  final String hospitalId;

  @override
  State<EditHospitalScreen> createState() => _EditHospitalScreenState();
}

class _EditHospitalScreenState extends State<EditHospitalScreen> {
  final _formKeyCV = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl;
  File? _pickedImage;
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('hospital');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _name = '';
  late String _description;
  late String _address;
  late String _phone;
  late String _latitude;
  late String _longitude;
  late String _price;

  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('hospital').doc(widget.hospitalId).get();
      if (docSnapshot.exists) {
        var hospitalData = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _name = hospitalData['name'];
          _latitude = hospitalData['latitude'];
          _longitude = hospitalData['longitude'];
          _description = hospitalData['description'];
          _address = hospitalData['address'];
          _phone = hospitalData['phone'];
          _price = hospitalData['price'];
          imageUrl = hospitalData['image'];
        });
      } else {
        print('No data found for this hospital');
      }
    } catch (e) {
      print('Error fetching hospital data: $e');
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

  _editHospital() async {
    final isValid = _formKeyCV.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKeyCV.currentState!.save();
    try {
      await _uploadImageToFirebase();
      await _firestore.collection('hospital').doc(widget.hospitalId).update({
        'name': _name,
        'description': _description,
        'address': _address,
        'phone': _phone,
        'price': _price,
        'latitude': _latitude,
        'longitude': _longitude,
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
                _editHospital();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Edit Hospital'),
            ),
          ),
        ],
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
                        initialValue: _description,
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
                      TextFormField(
                        initialValue: _price,
                        decoration: cvFormField('Price'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please fill in price';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          _price = value!;
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
                      const SizedBox(height: 16),
                      LocationInput(onSelectLocation: (location) {
                        _selectedLocation = location;
                      })
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
