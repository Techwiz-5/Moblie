import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techwiz_5/ui/widgets/schedule_card.dart';
import 'package:techwiz_5/ui/widgets/schedule_card_not_receive.dart';

class AccessBooking extends StatefulWidget {
  const AccessBooking({
    super.key,
    required this.driverId,
    required this.bookingId,
  });
  final String bookingId;
  final String driverId;

  @override
  State<AccessBooking> createState() => _AccessBookingState();
}

class _AccessBookingState extends State<AccessBooking> {
  final CollectionReference myItems =
  FirebaseFirestore.instance.collection('booking');
  @override
  void setState(VoidCallback fn) {
    print("testokroinha");
    print(widget.bookingId);
    print(widget.driverId);
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    // print("hhhh");
    // print(widget.driverId);
    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 241, 242, 243),
          appBar:
          AppBar(backgroundColor: Colors.blue, title: Text("Booking new")),
          body: StreamBuilder(
            stream: myItems
                .where('id', isEqualTo: widget.bookingId)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              final items = streamSnapshot.data!.docs;
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = items[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      // borderRadius: BorderRadius.circular(20),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ScheduleCardNotReceive(
                            booking: documentSnapshot,
                            driverId: widget.driverId,
                          )),
                    ),
                  );
                },
              );
            },
          ),
        ));

    // Scaffold(
    //   backgroundColor: Colors.blue[100],
    //   appBar: AppBar(
    //     backgroundColor: Colors.blue,
    //     title: const Text(
    //       'Driver Screen',
    //       style: TextStyle(
    //         color: Colors.white,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     centerTitle: true,
    //   ),
    //   body: Column(
    //     children: [
    //       // searchInput(),
    //       Flexible(
    //         child: StreamBuilder(
    //           stream: myItems
    //               .where('driver_id', isEqualTo: widget.driverId)
    //               .snapshots(),
    //           builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
    //             if (streamSnapshot.hasData) {
    //               final items = streamSnapshot.data!.docs;
    //               return ListView.builder(
    //                 itemCount: items.length,
    //                 itemBuilder: (context, index) {
    //                   final DocumentSnapshot documentSnapshot = items[index];

    //                   return Padding(
    //                     padding: const EdgeInsets.all(8.0),
    //                     child: Container(
    //                       // borderRadius: BorderRadius.circular(20),
    //                       child: Padding(
    //                           padding: const EdgeInsets.all(8.0),
    //                           child: Schedule_card(
    //                             booking: documentSnapshot,
    //                           )),
    //                     ),
    //                   );
    //                 },
    //               );
    //             }
    //             return const Center(
    //               child: CircularProgressIndicator(
    //                 color: Colors.blue,
    //               ),
    //             );
    //           },
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}
