import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techwiz_5/ui/driver/driver_google_map_pickup.dart';

class Schedule_card extends StatefulWidget {
  const Schedule_card({super.key, required this.booking, required this.roleCurrent});

  final dynamic booking;
  final dynamic roleCurrent;

  @override
  State<Schedule_card> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<Schedule_card> {
  final CollectionReference myItems = FirebaseFirestore.instance.collection('booking');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference hospital = FirebaseFirestore.instance.collection('hospital');
  late final QuerySnapshot querySnapshot;
  @override
  void initState() {
    super.initState();
    gethospital();
  }

  gethospital() async{
    querySnapshot = await hospital.where("id", isEqualTo: widget.booking['hospital_id']).get();
  }
  String statusText(int status) {
    if (status == 0) return 'Pending';
    if (status == 1) return 'Received';
    return 'Finish';
  }

  Color setColor(int status) {
    if (status == 0) return Colors.red;
    if (status == 1) return Colors.green;
    return Colors.blue;
  }

  bool showDriverButton() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    String bookingDate = DateFormat('yyyy-MM-dd').format(widget.booking['booking_time'].toDate());
    return widget.roleCurrent == 'driver' &&
        bookingDate == formattedDate &&
        statusText(widget.booking['status']) != 'Finish';
  }

  @override
  Widget build(BuildContext context) {
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
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      DateFormat('dd-MM-yyyy hh:mm').format(widget.booking['booking_time'].toDate()),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: setColor(widget.booking['status']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText(widget.booking['status']),
                    style: const TextStyle(
                      fontSize: 12,
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
                    'Address: ${widget.booking['address'] ?? ''}',
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
                    'From: ${querySnapshot.docs.toList()[0]['address'] ?? ''}',
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
            if (showDriverButton())
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverGoogleMapPickupPoint(
                          bookingId: widget.booking['id'],
                        ),
                      ),
                    ),
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
  }
}
