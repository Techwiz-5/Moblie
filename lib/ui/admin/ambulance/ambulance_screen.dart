import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/ambulance/create_ambulance.dart';
import 'package:techwiz_5/ui/widgets/ambulance_card.dart';

class AmbulanceScreen extends StatefulWidget {
  const AmbulanceScreen({super.key});

  @override
  State<AmbulanceScreen> createState() => _AmbulanceScreenState();
}

class _AmbulanceScreenState extends State<AmbulanceScreen> {
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
                print('Test : ');
                print(documentSnapshot['hospital_id']);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    // borderRadius: BorderRadius.circular(20),
                    // AmbulanceCard(
                    //     ambulance: documentSnapshot,
                    //   ),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0), child: Text('Hi')),
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
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AmbulanceFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
