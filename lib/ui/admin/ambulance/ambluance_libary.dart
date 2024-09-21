import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/ambulance/create_ambulance.dart';
import 'package:techwiz_5/ui/widgets/ambulance_card.dart';
import 'package:techwiz_5/ui/widgets/ambulance_libary_card.dart';

class AmbulanceLibraryScreen extends StatefulWidget {
  const AmbulanceLibraryScreen({super.key});
  // final dynamic ambulance;

  @override
  State<AmbulanceLibraryScreen> createState() => _AmbulanceLibraryScreenState();
}

class _AmbulanceLibraryScreenState extends State<AmbulanceLibraryScreen> {
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('ambulance');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(0.15),
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
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: AmbulanceLibraryCard(
                        ambulance: documentSnapshot,
                      ),
                    ),
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
    );
  }
}
