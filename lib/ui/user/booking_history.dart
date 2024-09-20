import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:techwiz_5/data/authentication.dart';
import 'package:techwiz_5/ui/login_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  String id = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _namePatient = '';
  String _address = '';
  String _phoneNumber = '';
  int _ambulanceType = 0;
  DateTime? selectedDate;
  LatLng? _selectedLocation;
  String selectHospitalId = '';
  int? status;
  List<Map<String, dynamic>> bookings = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Booking hospital',
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
              Icons.exit_to_app_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('booking').where("user_id", isEqualTo: id)
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
          final loadedMessages = chatSnapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INFORMATION',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Card(
                        //   elevation: 0,
                        //   color: Colors.white,
                        //   margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Column(
                        //       children: [
                        //         SizedBox(
                        //           width: double.infinity,
                        //           child: Card(
                        //             child: ListTile(
                        //               leading: const Icon(Icons.person),
                        //               title: Text(_name),
                        //             ),
                        //           ),
                        //         ),
                        //         SizedBox(
                        //           width: double.infinity,
                        //           child: Card(
                        //             child: ListTile(
                        //               leading: const Icon(Icons.home),
                        //               title: Text(_address),
                        //             ),
                        //           ),
                        //         ),
                        //         SizedBox(
                        //           width: double.infinity,
                        //           child: Card(
                        //             child: ListTile(
                        //               leading: const Icon(Icons.call),
                        //               title: Text(_phone),
                        //             ),
                        //           ),
                        //         ),
                        //         SizedBox(
                        //           width: double.infinity,
                        //           child: ElevatedButton(
                        //             onPressed: () => Navigator.push(
                        //               context,
                        //               MaterialPageRoute(
                        //                 builder: (context) =>
                        //                 const BookingHistoryScreen(),
                        //               ),
                        //             ),
                        //             child: Text("Booking History"),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
