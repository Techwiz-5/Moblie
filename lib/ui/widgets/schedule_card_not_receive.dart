import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/driver/driver_google_map_pickup.dart';

class Schedule_card_not_receive extends StatefulWidget {
  const Schedule_card_not_receive(
      {super.key, required this.booking, required this.driverId});
  final dynamic booking;
  final String driverId;
  @override
  State<Schedule_card_not_receive> createState() =>
      _ScheduleCardNotReceiveState();
}

class _ScheduleCardNotReceiveState extends State<Schedule_card_not_receive> {
  bool isAdmin = false;
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('booking');

  @override
  void initState() {
    super.initState();
  }

  void receiveBooking() async {
    await FirebaseFirestore.instance
        .collection('booking')
        .doc(widget.booking["id"])
        .update({
      'driver_id': widget.driverId,
    });
  }
  Future<void> _showMyDialog() async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure you want to take this booking??'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              // receiveBooking();
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
                    onPressed: () => _showMyDialog(),
                    child: const Text("Receive!"),
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
