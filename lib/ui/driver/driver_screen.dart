import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/widgets/schedule_card.dart';
import 'package:techwiz_5/ui/widgets/schedule_card_not_receive.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({
    super.key,
    required this.driverId,
    required this.roleCurrent,
  });
  final String roleCurrent;
  final String driverId;

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('booking');

  @override
  Widget build(BuildContext context) {
    // print("hhhh");
    // print(widget.driverId);
    return DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 241, 242, 243),
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: widget.roleCurrent == 'admin'
                ? const Text(
                    'Work Diary',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                : const Text(
                    'Booking Manager',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
            bottom: (widget.roleCurrent == 'driver')
                ? TabBar(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.white),
                    tabs: [
                      if (widget.roleCurrent == 'driver')
                        const Tab(
                          icon: Icon(Icons.event_available_rounded),
                        ),
                      if (widget.roleCurrent == 'driver')
                        const Tab(
                          icon: Icon(Icons.event_note_rounded),
                        ),
                    ],
                  )
                : null,
          ),
          body: TabBarView(
            children: <Widget>[
              Column(children: [
                // searchInput(),
                Flexible(
                  child: StreamBuilder(
                    stream: myItems
                        .where('driver_id', isEqualTo: widget.driverId)
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        final items = streamSnapshot.data!.docs;
                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                                items[index];

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                // borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Schedule_card(
                                        booking: documentSnapshot,
                                        roleCurrent: widget.roleCurrent)),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ]),
              Column(children: [
                // searchInput(),
                Flexible(
                  child: StreamBuilder(
                    stream:
                        myItems.where('driver_id', isEqualTo: "").snapshots(),
                    builder:
                        (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                      if (streamSnapshot.hasData) {
                        final items = streamSnapshot.data!.docs;
                        return ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final DocumentSnapshot documentSnapshot =
                                items[index];

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                // borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Schedule_card_not_receive(
                                        booking: documentSnapshot,
                                        driverId: widget.driverId)),
                              ),
                            );
                          },
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ]),
            ],
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
