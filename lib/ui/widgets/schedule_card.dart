import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
          const ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Center(
                child: Stack(
              alignment: Alignment.bottomLeft,
              children: <Widget>[
                // Image.network(
                //   widget.hospital['image'],
                //   width: double.infinity,
                //   height: 205,
                //   fit: BoxFit.cover,
                // ),
              ],
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        height: 40,
                        child:
                            // Text(
                            //   widget.booking['driver_id'].toString(),
                            //   maxLines: 2,
                            //   overflow: TextOverflow.ellipsis,
                            //   softWrap: true,
                            //   style: const TextStyle(
                            //     color: Colors.red,
                            //     fontWeight: FontWeight.bold,
                            //     fontSize: 18,
                            //   ),
                            // ),
                            Switch(
                          // This bool value toggles the switch.
                          value: widget.booking['urgent'] == 1 ? true : false,
                          activeColor: Colors.red,
                          onChanged: (bool value) {},
                        )),
                  ],
                ),
                Text(
                  widget.booking['urgent'].toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            HospitalDetailScreen(hospital: widget.booking),
                      ),
                    ),
                    child: const Text("View detail"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[100]),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
