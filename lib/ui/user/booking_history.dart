import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/widgets/booking_card.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String id = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Booking History',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white)),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('booking')
            .where("user_id", isEqualTo: id)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No message found'),
            );
          }
          if (chatSnapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
          final bookingData = chatSnapshot.data!.docs;
          return ListView.builder(
            itemCount: bookingData.length,
            itemBuilder: (ctx, index) {
              return Container(
                margin: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                child: BookingCard(booking: bookingData[index]),
              );
            },
          );
        },
      ),
    );
  }
}
