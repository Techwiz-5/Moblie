import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/widgets/schedule_card.dart';
import 'package:techwiz_5/ui/widgets/schedule_card_not_receive.dart';

class DriverScreen extends StatefulWidget with WidgetsBindingObserver {
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
class _DriverScreenState extends State<DriverScreen> with WidgetsBindingObserver {
  late CollectionReference myItems;
  bool check = false;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();

    myItems = FirebaseFirestore.instance.collection('booking');
    WidgetsBinding.instance.addObserver(this);
    checkStatusDriver();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        checkStatusDriver();
      });
    }
  }

  checkStatusDriver() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot docSnapshot = await _firestore.collection('driver').doc(uid).get();

    if (docSnapshot.exists && docSnapshot.data() != null) {
      Map<String, dynamic>? data = docSnapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('status')) {
        String status = data['status'];

        if (status != "1") {
          setState(() {
            check = true;
          });
        } else {
          setState(() {
            check = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const Tab(
                icon: Icon(Icons.event_available_rounded),
              ),
              const Tab(
                icon: Icon(Icons.event_note_rounded),
              ),
              const Tab(
                icon: Icon(Icons.note_alt),
              ),
            ],
          )
              : null,
        ),
        body: TabBarView(
          children: <Widget>[
            _buildScheduleList('driver_id', widget.driverId, 4),
            _buildScheduleList1('driver_id', widget.driverId, [1, 2,3]),
            _buildNotReceivedScheduleList(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList(String field, String value, int status) {
    return Column(children: [
      Flexible(
        child: StreamBuilder(
          stream: myItems.where(field, isEqualTo: value).where('status', isEqualTo: status).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              final items = streamSnapshot.data!.docs;
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = items[index];
                  return Schedule_card(
                      booking: documentSnapshot, roleCurrent: widget.roleCurrent);
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
    ]);
  }

  Widget _buildScheduleList1(String field, String value, List<int> statuses) {
    return Column(children: [
      Flexible(
        child: StreamBuilder(
          stream: myItems
              .where(field, isEqualTo: value)
              .where('status', whereIn: statuses)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              final items = streamSnapshot.data!.docs;
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = items[index];
                  return Schedule_card(
                      booking: documentSnapshot, roleCurrent: widget.roleCurrent);
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
    ]);
  }

  Widget _buildNotReceivedScheduleList() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);

    return Column(children: [
      Flexible(
        child: StreamBuilder(
          stream: myItems
              .where('driver_id', isEqualTo: "")
              .where('status', isEqualTo: 0)
              .where('booking_time', isGreaterThanOrEqualTo: startOfDay)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              final items = streamSnapshot.data!.docs;
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = items[index];
                  return ScheduleCardNotReceive(
                      booking: documentSnapshot, driverId: widget.driverId);
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
    ]);
  }
}


