import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:techwiz_5/data/authentication.dart';
import 'package:techwiz_5/data/google_auth.dart';
import 'package:techwiz_5/ui/login_screen.dart';
import 'package:techwiz_5/ui/user/profile/edit_profile_screen.dart';
import 'package:techwiz_5/ui/widgets/button.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String imageUrl;
  late String _name;
  late String _email = '';
  late String _phone;
  late String _address;

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
        actions: [
          IconButton(
            onPressed: () async {
              await AuthServices().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(
              Icons.exit_to_app_rounded,
              color: Colors.white,
            ),
          ),
        ],
        leading: IconButton(
          onPressed: () async {
            bool? result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  hospitalId: FirebaseAuth.instance.currentUser!.uid,
                ),
              ),
            );
            if (result == true) {
              // Profile was updated, refresh the data
              getUserData();
            }
          },
          icon: const Icon(
            Icons.edit,
            color: Colors.white,
          ),
        ),
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
                                backgroundImage: NetworkImage(imageUrl.isEmpty || imageUrl == null
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
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(_name),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.home),
                            title: Text(_address),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.call),
                            title: Text(_phone),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // const SizedBox(height: 16),
        // Container(
        //   width: double.infinity,
        //   margin: const EdgeInsets.symmetric(horizontal: 10),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       const Text(
        //         'CONTACT',
        //         style: TextStyle(fontWeight: FontWeight.bold),
        //       ),
        //       Card(
        //         elevation: 0,
        //         color: Colors.white,
        //         margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        //         child: Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: Column(
        //             children: [
        //               SizedBox(
        //                 width: double.infinity,
        //                 child: ElevatedButton.icon(
        //                   style: ElevatedButton.styleFrom(
        //                     surfaceTintColor: Colors.white,
        //                     backgroundColor: Colors.white,
        //                     alignment: Alignment.centerLeft,
        //                     foregroundColor: Colors.black54,
        //                   ),
        //                   icon: Image.asset('assets/images/zalo.png',
        //                       height: 22, color: Colors.black54),
        //                   label: const Text('Zalo'),
        //                   onPressed: () async {
        //                     try {
        //                       await launchUrl(
        //                         Uri.parse('http://zalo.me/09012345678'),
        //                       );
        //                     } catch (e) {
        //                       throw 'Could not launch url';
        //                     }
        //                   },
        //                 ),
        //               ),
        //               SizedBox(
        //                 width: double.infinity,
        //                 child: ElevatedButton.icon(
        //                   style: ElevatedButton.styleFrom(
        //                     surfaceTintColor: Colors.white,
        //                     backgroundColor: Colors.white,
        //                     alignment: Alignment.centerLeft,
        //                     foregroundColor: Colors.black54,
        //                   ),
        //                   icon: Image.asset(
        //                     'assets/images/facebook_icon.png',
        //                     height: 22,
        //                     color: Colors.black54,
        //                   ),
        //                   label: const Text('PHTV Fanpage'),
        //                   onPressed: () async {
        //                     try {
        //                       await launchUrl(
        //                         Uri.parse('https://www.facebook.com/phtvpro'),
        //                       );
        //                     } catch (e) {
        //                       throw 'Could not launch url';
        //                     }
        //                   },
        //                 ),
        //               ),
        //               SizedBox(
        //                 width: double.infinity,
        //                 child: ElevatedButton.icon(
        //                   style: ElevatedButton.styleFrom(
        //                     surfaceTintColor: Colors.white,
        //                     backgroundColor: Colors.white,
        //                     alignment: Alignment.centerLeft,
        //                     foregroundColor: Colors.black54,
        //                   ),
        //                   icon: const Icon(EneftyIcons.call_outline),
        //                   label: const Text('Hotline'),
        //                   onPressed: () async {
        //                     final Uri launchUri = Uri(
        //                       scheme: 'tel',
        //                       path: '09012345678',
        //                     );
        //                     await launchUrl(launchUri);
        //                   },
        //                 ),
        //               ),
        //               SizedBox(
        //                 width: double.infinity,
        //                 child: ElevatedButton.icon(
        //                   style: ElevatedButton.styleFrom(
        //                     surfaceTintColor: Colors.white,
        //                     backgroundColor: Colors.white,
        //                     alignment: Alignment.centerLeft,
        //                     foregroundColor: Colors.black54,
        //                   ),
        //                   icon: const Icon(Icons.mail_outline),
        //                   label: const Text('Email'),
        //                   onPressed: () async {
        //                     String? encodeQueryParameters(
        //                         Map<String, String> params) {
        //                       return params.entries
        //                           .map((MapEntry<String, String> e) =>
        //                       '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        //                           .join('&');
        //                     }
        //                     final Uri launchUri = Uri(
        //                       scheme: 'mailto',
        //                       path: 'phtvpro@gmail.com',
        //                       query: encodeQueryParameters(<String, String>{
        //                         'subject': 'Hello PHTV Pro, I have question',
        //                       }),
        //                     );
        //                     await launchUrl(launchUri);
        //                   },
        //                 ),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // TextButton(
        //   style: TextButton.styleFrom(
        //     foregroundColor: Colors.red,
        //   ),
        //   onPressed: () {
        //     showDialog(
        //       context: context,
        //       builder: (context) {
        //         return AlertDialog(
        //           title: const Text('You are signing out?'),
        //           content: const SingleChildScrollView(
        //             child: ListBody(
        //               children: <Widget>[
        //                 Text('You are about to sign out our app'),
        //                 Text('Would you please confirm?'),
        //               ],
        //             ),
        //           ),
        //           backgroundColor: Colors.white,
        //           elevation: 0,
        //           actions: <Widget>[
        //             TextButton(
        //               child: const Text('Cancel'),
        //               onPressed: () {
        //                 Navigator.of(context).pop();
        //               },
        //             ),
        //             ElevatedButton(
        //               child: const Text('Signout'),
        //               onPressed: () {
        //                 deleteAuthAll();
        //                 Navigator.of(context).pop();
        //               },
        //             ),
        //
        //           ],
        //         );
        //       },
        //     );
        //   },
        //   child: isLoggedIn ? const Text('Sign out') : const SizedBox.shrink(),
        // ),
        // const SizedBox(height: 20),
      ],
    );
  }
}
