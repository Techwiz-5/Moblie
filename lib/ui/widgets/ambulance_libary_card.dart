import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/ambulance/create_ambulance.dart';
import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance_screen.dart';
import 'package:techwiz_5/ui/widgets/ribbon.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
// import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance.dart';

class AmbulanceLibraryCard extends StatefulWidget {
  const AmbulanceLibraryCard({super.key, required this.ambulance});
  final dynamic ambulance;

  @override
  State<AmbulanceLibraryCard> createState() => _AmbulanceLibraryCardState();
}

class _AmbulanceLibraryCardState extends State<AmbulanceLibraryCard> {
  String? hospitalName;
  String? hospitalPhone;
  String? hospitalAddress;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchHospital();
  }

  void _fetchHospital() async {
    DocumentSnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('hospital')
        .doc(widget.ambulance['hospital_id'])
        .get();
    print(querySnapshot.toString());
    var ambulanceData = querySnapshot.data() as Map<String, dynamic>;
    setState(() {
      hospitalName = ambulanceData['name'];
      hospitalPhone = ambulanceData['phone'];
      hospitalAddress = ambulanceData['address'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
          Stack(
            children: <Widget>[
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.bottomLeft,
                    children: <Widget>[
                      Image.network(
                        widget.ambulance['image'],
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(0.5),
            child: Card(
              color: Colors.white,
              borderOnForeground: false,
              shadowColor: Colors.white,
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hospital Name : ${hospitalName} ',
                      style: const TextStyle(
                        // height: 2,
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Phone Hospital : ${hospitalPhone} ',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      'Type : ${widget.ambulance['type']} ',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      'Plate Number : ${widget.ambulance['plate_number']} ',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.normal,
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
    ;
  }
}
