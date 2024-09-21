import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/ambulance/create_ambulance.dart';
import 'package:techwiz_5/ui/widgets/ambulance_card.dart';
import 'package:techwiz_5/ui/widgets/booking_card.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('booking');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(0.15),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Booking Manager',
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
                  padding: const EdgeInsets.only(
                      right: 4.0, left: 4, top: 2, bottom: 2),
                  child: Container(
                    // borderRadius: BorderRadius.circular(20),
                    child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: BookingCard(
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
    );
  }
}
