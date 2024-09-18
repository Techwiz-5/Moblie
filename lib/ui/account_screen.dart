import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/edit_screen.dart';
import 'package:crud/login_screen.dart';
import 'package:crud/manager_screen.dart';
import 'package:crud/myapp.dart';
import 'package:crud/services/authentication.dart';
import 'package:crud/services/google_auth.dart';
import 'package:crud/user_screen.dart';
import 'package:crud/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return await _firestore.collection('users').doc(uid).get();
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
            if(userData['role'] == 'user'){
              return UserScreen(userData: userData);
            } else if(userData['role'] == 'manager') {
              return ManagerScreen(userData: userData);
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
