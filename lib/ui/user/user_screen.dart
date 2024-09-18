import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/authentication.dart';
import '../../data/google_auth.dart';
import '../login_screen.dart';
import '../widgets/button.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return await _firestore.collection('account').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'User Screen',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: getUserData(),
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
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 90,
                          backgroundImage: NetworkImage(
                            FirebaseAuth.instance.currentUser!.photoURL ??
                                (userData['image'] ??
                                    'https://via.placeholder.com/150'),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "UID: ${userData['uid']}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Email: ${userData['email']}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Name: ${userData['name']}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Phone: ${userData['phone']}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // MyButtons(
                  //   onTap: () {
                  //     Navigator.of(context).pushReplacement(
                  //       MaterialPageRoute(builder: (context) => const EditScreen()),
                  //     );
                  //   },
                  //   text: 'Edit',
                  // ),
                  // ElevatedButton(onPressed: () => FlutterPhoneDirectCaller.callNumber('+84949181836'), child: Text("Call")),
                  MyButtons(
                    onTap: () async {
                      if (FirebaseAuth
                          .instance.currentUser!.providerData[0].providerId ==
                          'google.com') {
                        await FirebaseServices().googleSignOut();
                      } else {
                        await AuthServices().logout();
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    text: 'Log Out',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
