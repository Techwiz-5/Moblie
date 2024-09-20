import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/widgets/hospital_card.dart';
import 'package:techwiz_5/ui/widgets/schedule_card.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final CollectionReference myItems = FirebaseFirestore.instance
          .collection('booking');
          Stream<QuerySnapshot> getAcceptedBookings() {
  return myItems.where('driver_id', isEqualTo: '1').snapshots();
}
      

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Driver Screen',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // searchInput(),
          Flexible(
            child: StreamBuilder(
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
                              child: Schedule_card(
                                booking: documentSnapshot,
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
          ),
        ],
      ),
    );
  }
}
