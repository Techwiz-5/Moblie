import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:techwiz_5/data/authentication.dart';
import 'package:techwiz_5/data/google_auth.dart';
import 'package:techwiz_5/ui/login_screen.dart';
import 'package:techwiz_5/ui/user/booking_history.dart';
import 'package:techwiz_5/ui/user/profile/edit_profile_screen.dart';
import 'package:techwiz_5/ui/widgets/button.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKeyCV = GlobalKey<FormState>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String imageUrl;
  late String _name;
  late String _email = '';
  late String _phone;
  late String _address;
  late String _role;
  String title = "";
  String description = "";
  File? _pickedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot docSnapshot;

      docSnapshot = await _firestore.collection('account').doc(uid).get();

      if (!docSnapshot.exists) {
        docSnapshot = await _firestore.collection('driver').doc(uid).get();
      }

      if (docSnapshot.exists) {
        var userData = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _name = userData['name'];
          _email = userData['email'];
          _phone = userData['phone'];
          _address = userData['address'];
          _role = userData['role'];
          imageUrl = userData['image'];
        });
      } else {
        showSnackBar(context, 'User does not exist in both collections');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(0.15),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthServices().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(
              EneftyIcons.logout_2_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: (_email.isEmpty)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Card(
                        elevation: 0,
                        color: Colors.white,
                        margin:
                            const EdgeInsets.only(top: 60, left: 10, right: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 70),
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    _name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(FluentIcons.mail_16_filled),
                                  title: Text(_email),
                                ),
                                ListTile(
                                  leading: const Icon(FluentIcons.home_16_filled),
                                  title: Text(_address),
                                ),
                                ListTile(
                                  leading: const Icon(EneftyIcons.call_bold),
                                  title: Text(_phone),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 15),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.grey.withOpacity(0.5),
                          child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    imageUrl.isEmpty || imageUrl == null
                                        ? 'https://via.placeholder.com/150'
                                        : imageUrl),
                                radius: 44,
                              )),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  myAction(),
                ],
              ),
            ),
    );
  }

  sendfeedback() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot docSnapshot;
    docSnapshot = await _firestore.collection('account').doc(uid).get();
    if (!docSnapshot.exists) {
      docSnapshot = await _firestore.collection('driver').doc(uid).get();
    }
    var userData = docSnapshot.data() as Map<String, dynamic>;

    try {
      await FirebaseFirestore.instance.collection("feedback").add({
        'title': title,
        'description': description,
        "user_name": userData['name'],
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please enter your feedback'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter title',
                      ),
                      autocorrect: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please field name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        title = value!;
                      },
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter content',
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please field in description';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        description = value!;
                      },
                    ),
                    const SizedBox(height: 16),

                    // LocationInput(onSelectLocation: (location) {
                    // _selectedLocation = location;
                    // })
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Send'),
              onPressed: () {
                sendfeedback();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget myAction() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INFORMATION',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _role == 'user'
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Card(
                                child: ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Edit Profile'),
                                  onTap: () async {
                                    bool? result =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => EditProfileScreen(
                                          hospitalId: FirebaseAuth
                                              .instance.currentUser!.uid,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      // Profile was updated, refresh the data
                                      getUserData();
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Card(
                                child: ListTile(
                                  leading: const Icon(FluentIcons.history_16_filled),
                                  title: const Text('Booking History'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const BookingHistoryScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Card(
                                child: ListTile(
                                  leading: const Icon(FluentIcons.comment_16_filled),
                                  title: const Text('Feedback'),
                                  onTap: () {
                                    _showMyDialog();
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
