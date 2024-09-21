import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/ambulance/create_ambulance.dart';
import 'package:techwiz_5/ui/widgets/ambulance_card.dart';
import 'package:techwiz_5/ui/widgets/schedule_card.dart';
import 'package:techwiz_5/ui/widgets/schedule_card_not_receive.dart';

class AmabulanceOfHospitalScreen extends StatefulWidget {
  const AmabulanceOfHospitalScreen({
    super.key,
    required this.hospital_id,
  });

  final String hospital_id;

  @override
  State<AmabulanceOfHospitalScreen> createState() =>
      _AmabulanceOfHospitalScreenState();
}

class _AmabulanceOfHospitalScreenState
    extends State<AmabulanceOfHospitalScreen> {
  initState() {
    super.initState();
    getUserData();
  }

  String _role = '';
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('ambulance');
  var isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void getUserData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot docSnapshot;

      docSnapshot = await _firestore.collection('account').doc(uid).get();
      if (!docSnapshot.exists) {
        docSnapshot = await _firestore.collection('driver').doc(uid).get();
      }
      var userData = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _role = userData['role'];
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: const Text(
              'Abulance Manager',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: StreamBuilder(
            stream: myItems
                .where('hospital_id', isEqualTo: widget.hospital_id)
                .snapshots(),
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
                            child: AmbulanceCard(
                              ambulance: documentSnapshot,
                              // roleCurrent: widget.roleCurrent
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
          floatingActionButton: (_role == 'admin')
              ? FloatingActionButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AmbulanceFormScreen())),
                  child: const Icon(Icons.add),
                )
              : null,
        ));
  }
}
