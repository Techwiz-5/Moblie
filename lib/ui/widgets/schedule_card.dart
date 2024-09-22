import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techwiz_5/ui/driver/driver_google_map_pickup.dart';

class Schedule_card extends StatefulWidget {
  const Schedule_card(
      {super.key, required this.booking, required this.roleCurrent});

  final dynamic booking;
  final dynamic roleCurrent;

  @override
  State<Schedule_card> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<Schedule_card> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  QuerySnapshot? querySnapshot;
  DocumentSnapshot? docSnapshotBooking;
  DocumentSnapshot? driverSnapshot;
  bool isLoading = true;
  bool checkNowBooking = false;

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    querySnapshot = await getHospital();
    docSnapshotBooking = await getBookingStatus();
    setState(() {
      isLoading = false;
    });
  }

  Future<QuerySnapshot> getHospital() async {
    return await _firestore
        .collection('hospital')
        .where("id", isEqualTo: widget.booking['hospital_id'])
        .get();
  }

  Future<DocumentSnapshot?> getBookingStatus() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    driverSnapshot =
    await FirebaseFirestore.instance.collection('driver').doc(uid).get();

    QuerySnapshot querySnapshot = await _firestore
        .collection('booking')
        .where('id', isEqualTo: widget.booking['id'])
        .where('driver_id', isEqualTo: uid)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    } else {
      return null;
    }
  }

  String statusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Received';
      case 2:
        return 'Picking up the patient';
      case 3:
        return 'Heading to the hospital';
      default:
        return 'Finish';
    }
  }

  Color setColor(int status) {
    switch (status) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<bool> showDriverButton() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String bookingDate =
    DateFormat('yyyy-MM-dd').format(widget.booking['booking_time'].toDate());

    if (bookingDate == formattedDate && driverSnapshot!['enable'] == 0) {
      return true;
    }
    return false;
  }

  Future<bool> shouldShowGoogleMapButton() async {
    if (docSnapshotBooking != null &&
        (docSnapshotBooking!['status'] == 2 || docSnapshotBooking!['status'] == 3)) {
      return true;
    }
    if (docSnapshotBooking != null &&
        (docSnapshotBooking!['status'] == 4)) {
      return false;
    }

    return await showDriverButton();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<bool>(
      future: shouldShowGoogleMapButton(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blue, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          DateFormat('dd-MM-yyyy hh:mm').format(widget.booking['booking_time'].toDate()),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                      decoration: BoxDecoration(
                        color: setColor(widget.booking['status']),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusText(widget.booking['status']),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'From:  ${widget.booking['address'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'To:  ${querySnapshot?.docs.first['address'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Name Patient: ${widget.booking['name_patient'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Phone: ${widget.booking['phone_number'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                if (snapshot.data == true)
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverGoogleMapPickupPoint(
                                bookingId: widget.booking['id'],
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[100],
                        ),
                        child: const Text("View Google Map"),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
