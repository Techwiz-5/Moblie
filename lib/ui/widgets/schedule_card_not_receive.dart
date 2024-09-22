import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techwiz_5/ui/driver/driver_google_map_pickup.dart';

class ScheduleCardNotReceive extends StatefulWidget {
  const ScheduleCardNotReceive(
      {super.key, required this.booking, required this.driverId});
  final dynamic booking;
  final String driverId;

  @override
  State<ScheduleCardNotReceive> createState() => _ScheduleCardNotReceiveState();
}

class _ScheduleCardNotReceiveState extends State<ScheduleCardNotReceive> {
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('booking');
  late final Stream<QuerySnapshot<Map<String, dynamic>>> bookingOfDriver;
  bool isLoading = true;

  late final CollectionReference hospital =
      FirebaseFirestore.instance.collection('hospital');
  late final QuerySnapshot querySnapshot;

  @override
  void initState() {
    super.initState();
    gethospital();
  }

  gethospital() async {
    querySnapshot = await hospital
        .where("id", isEqualTo: widget.booking['hospital_id'])
        .get();
    setState(() {
      isLoading = false;
    });
  }

  String statusText(int status) {
    if (status == 0) return 'Pending';
    if (status == 1) return 'Received';
    return 'Finish';
  }

  Color setColor(int status) {
    if (status == 0) return Colors.redAccent;
    if (status == 1) return Colors.greenAccent;
    return Colors.blueAccent;
  }

  void receiveBooking() async {
    await FirebaseFirestore.instance
        .collection('booking')
        .doc(widget.booking["id"])
        .update({
      'driver_id': widget.driverId,
      'status': 1,
    });
    Navigator.pop(context);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Booking'),
          content: const Text('Are you sure you want to take this booking?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Receive'),
              onPressed: () {
                receiveBooking();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent, width: 2),
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd-MM-yyyy hh:mm')
                          .format(widget.booking['booking_time'].toDate()),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    color: setColor(widget.booking['status']),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText(widget.booking['status']),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildInfoRow(Icons.location_on, 'Address: ',
                widget.booking['address'] ?? 'No address provided'),
            const SizedBox(height: 10),
            _buildInfoRow(
                Icons.location_on,
                'From: ',
                querySnapshot.docs.toList()[0]['address'] ??
                    'No address provided'),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.person, 'Patient Name: ',
                widget.booking['name_patient'] ?? 'No name provided'),
            const SizedBox(height: 10),
            _buildInfoRow(Icons.phone, 'Phone: ',
                widget.booking['phone_number'] ?? 'No phone number'),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showMyDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[100],
                  ),
                  child: const Text("Receive Booking"),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String info) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label $info',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
