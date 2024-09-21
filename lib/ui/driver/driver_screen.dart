import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/widgets/schedule_card.dart';
import 'package:techwiz_5/ui/widgets/schedule_card_not_receive.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key, required this.driverId});
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
          backgroundColor: Colors.blue[100],
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: const Text('TabBar Sample'),
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                gradient: const LinearGradient(colors: [
                  Color.fromARGB(255, 35, 158, 225),
                  Color.fromARGB(255, 250, 250, 250)
                ]),
                borderRadius: BorderRadius.circular(50),
              ),
              tabs: const <Widget>[
                Tab(
                  icon: Icon(Icons.event_available_rounded),
                ),
                Tab(
                  icon: Icon(Icons.event_note_rounded),
                ),
              ],
            ),
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
              Column(children: [
                // searchInput(),
                Flexible(
                  child: StreamBuilder(
                    stream: myItems
                        .where('driver_id', isEqualTo: "")
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
                                    child: Schedule_card_not_receive(
                                      booking: documentSnapshot,driverId: widget.driverId
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

