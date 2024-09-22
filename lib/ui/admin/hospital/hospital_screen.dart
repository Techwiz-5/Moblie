import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/data/authentication.dart';
import 'package:techwiz_5/ui/admin/hospital/create_hospital_screen.dart';
import 'package:techwiz_5/ui/login_screen.dart';
import 'package:techwiz_5/ui/widgets/button.dart';
import 'package:techwiz_5/ui/widgets/hospital_card.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});
  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('hospital');
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff475e75),
      appBar: AppBar(
        backgroundColor: const Color(0xff223548),
        title: const Text(
          'Hospital',
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
              EneftyIcons.logout_2_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: myItems.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            final items = streamSnapshot.data!.docs;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = items[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // borderRadius: BorderRadius.circular(20),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: HospitalCard(
                          hospital: documentSnapshot,
                        )),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HospitalFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
