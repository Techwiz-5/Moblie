import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance_screen.dart';
import 'package:techwiz_5/ui/admin/hospital/edit_hospital_screen.dart';
import 'package:techwiz_5/ui/driver/driver_page.dart';
import 'package:techwiz_5/ui/user/hospital_detail_screen.dart';

class DriverCard extends StatefulWidget {
  const DriverCard({super.key, required this.account});

  final dynamic account;

  @override
  State<DriverCard> createState() => _DriverCardState();
}

class _DriverCardState extends State<DriverCard> {
  final CollectionReference myItems =
  FirebaseFirestore.instance.collection('driver');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: const Border(
            left: BorderSide(
              color: Colors.blue,
              width: 6.0,
            ),
            top: BorderSide(
              color: Colors.blue,
              width: 1.0,
            ),
            right: BorderSide(
              color: Colors.blue,
              width: 1.0,
            ),
            bottom: BorderSide(
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
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                      color: const Color(0xff7c94b6),
                      image: DecorationImage(
                        image: NetworkImage(widget.account['image'] ??
                            "https://firebasestorage.googleapis.com/v0/b/techwiz-e0599.appspot.com/o/image%2Fdriver%2Fuser.jpg?alt=media&token=f488877a-05cc-49b8-90a0-41390cf949f9"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(50.0),
                      ),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name : ${widget.account['name']}',
                        style: const TextStyle(
                          height: 2,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Phone : ${widget.account['phone']}',
                        style: const TextStyle(
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 12, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email : ${widget.account['email']}',
                    style: const TextStyle(
                      height: 1.5,
                    ),
                  ),
                  Text(
                    'Address : ${widget.account['address']}',
                    style: const TextStyle(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.account['role'] == 'driver')
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width, // Full màn hình
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DriverPage(
                                driverId: widget.account['uid'],
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[100],
                          ),
                          child: const Text("Work diary"),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
