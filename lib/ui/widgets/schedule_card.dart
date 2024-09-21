import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techwiz_5/ui/driver/driver_google_map_pickup.dart';
import 'package:techwiz_5/ui/user/hospital_detail_screen.dart';

class Schedule_card extends StatefulWidget {
  const Schedule_card({super.key, required this.booking});
  final dynamic booking;
  @override
  State<Schedule_card> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<Schedule_card> {
  bool isAdmin = false;
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('booking');

  @override
  void initState() {
    super.initState();
  }

  String statusText(int status) {
    if (status == 0)
      return 'Pending';
    else if (status == 1) return 'Running';
    return 'Finish';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: const Border(
            left: BorderSide(
              //                   <--- left side
              color: Colors.blue,
              width: 6.0,
            ),
            top: BorderSide(
              //                    <--- top side
              color: Colors.blue,
              width: 1.0,
            ),
            right: BorderSide(
              //                    <--- top side
              color: Colors.blue,
              width: 1.0,
            ),
            bottom: BorderSide(
              //                    <--- top side
              color: Colors.blue,
              width: 1.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              spreadRadius: 0,
              blurRadius: 10,
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 0.5, left: 0.5),
            child: Card(
              color: Colors.white,
              borderOnForeground: false,
              shadowColor: Colors.white,
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('dd-MM-yyyy hh:mm').format(
                                widget.booking['booking_time'].toDate()),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Badge(
                            label: Text(statusText(widget.booking['status'])),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color.fromARGB(255, 147, 148, 148),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            'Address : ${widget.booking['address']} ' ?? '',
                            // maxLines: ,
                            // overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.accessible_rounded,
                          color: Color.fromARGB(255, 147, 148, 148),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            'Name Patient : ${widget.booking['name_patient']}' ??
                                '',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Color.fromARGB(255, 147, 148, 148),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            'Phone : ${widget.booking['phone_number']}' ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    const SizedBox(height: 8),
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
                          child: const Text("View Google Map"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
