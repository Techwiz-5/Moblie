import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/widgets/hospital_card.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  final CollectionReference myItems = FirebaseFirestore.instance.collection('hospital');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(0.15),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Hospital',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                        child: HospitalCard(hospital: documentSnapshot,)
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
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        child: const Icon(Icons.add),
      ),
    );
  }
}
