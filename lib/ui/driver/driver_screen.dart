import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    // print("hhhh");
    // print(widget.driverId);
    return DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 241, 242, 243),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 223, 113, 17),
            centerTitle: true,
            title: widget.roleCurrent == 'admin'
                ? const Text(
                    'Work Diary',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )
                : const Text(
                    'Booking Managers',
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
                      if (widget.roleCurrent == 'driver')
                        const Tab(
                          icon: Icon(Icons.note_alt),
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
                        .where('status', isEqualTo: 2)
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
                    stream: myItems
                        .where('driver_id', isEqualTo: widget.driverId)
                        .where('status', isEqualTo: 1)
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
                    myItems
                        .where('driver_id', isEqualTo: "")
                        .where('status', isEqualTo: 0)
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
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: myItems
                                          .where("driver_id",
                                          isEqualTo: widget.driverId)
                                          .snapshots(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot>
                                          snapshot) {
                                        // bool check = true;
                                        // if (snapshot.data != null) {
                                        //   for (var document
                                        //   in snapshot.data!.docs) {
                                        //     Map<String, dynamic> data =
                                        //     document.data()!
                                        //     as Map<String, dynamic>;
                                        //     if (documentSnapshot["status"] !=
                                        //         3) {
                                        //       if (DateFormat('dd-MM-yyyy')
                                        //           .format(
                                        //           data["booking_time"]
                                        //               .toDate()) ==
                                        //           DateFormat('dd-MM-yyyy')
                                        //               .format(documentSnapshot[
                                        //           "booking_time"]
                                        //               .toDate())) {
                                        //         check = false;
                                        //       }
                                        //     }
                                        //   }
                                        // }

                                        // if (check) {
                                          print(documentSnapshot["user_id"]);
                                          return ScheduleCardNotReceive(
                                              booking: documentSnapshot,
                                              driverId: widget.driverId);
                                        // } else {
                                        //   return Container();
                                        // }
                                      },
                                    )),
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

  }
}
