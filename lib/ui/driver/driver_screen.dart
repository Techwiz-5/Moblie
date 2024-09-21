import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});
  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String driverId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  void _setupFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['type'] == 'new_booking') {
        // Refresh the screen to show new booking
        setState(() {});
      }
    });
  }

  Future<void> _respondToBooking(String bookingId, bool accept) async {
    try {
      await _firestore.collection('booking').doc(bookingId).update({
        'status': accept ? 'accepted' : 'rejected',
        'driver_id': accept ? driverId : FieldValue.delete(),
      });
      // Refresh the screen
      setState(() {});
    } catch (e) {
      print('Error responding to booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error responding to booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          "Booking",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('booking')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No available bookings'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var booking = snapshot.data!.docs[index];
              return Card(
                child: ListTile(
                  title: Text('Patient: ${booking['name_patient']}'),
                  subtitle: Text('Address: ${booking['address']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => _respondToBooking(booking.id, true),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => _respondToBooking(booking.id, false),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}