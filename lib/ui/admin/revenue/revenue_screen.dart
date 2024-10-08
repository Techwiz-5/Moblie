import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/authentication.dart';
import '../../login_screen.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {


  DateFormat dateFormat = DateFormat("dd-MM-yyyy");
  final now = DateTime.now();
  late DateTime startdate;
  late DateTime enddate;
  late final myItems;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      startdate = DateTime(now.year, now.month, 0).add(const Duration(days: 1));
      enddate = DateTime(now.year, now.month + 1, 0);
      myItems = FirebaseFirestore.instance.collection('booking')
          .where('create_at', isGreaterThan: startdate)
          .where('create_at', isLessThan: enddate);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange? newSelectedDate = await showDateRangePicker(
      context: context,
        initialDateRange: DateTimeRange(start: startdate, end: enddate),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100)
    );
    if (newSelectedDate != null) {
      setState(() {
        startdate = newSelectedDate.start;
        enddate = newSelectedDate.end;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff475e75),
      appBar: AppBar(
        backgroundColor: const Color(0xff223548),
        title: const Text(
          'Revenue',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await AuthServices().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(
              EneftyIcons.logout_2_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: Colors.white70)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${dateFormat.format(startdate)} - ${dateFormat.format(enddate)}'),
                    const Icon(Icons.calendar_month_outlined)
                  ],
                ),
              ),
            ),
            Flexible(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('booking')
                    .where('create_at', isGreaterThan: startdate)
                    .where('create_at', isLessThan: enddate)
                    .snapshots(),
                builder: (ctx, chatSnapshot) {
                  if (chatSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No booking found'),
                    );
                  }
                  if (chatSnapshot.hasError) {
                    return const Center(
                      child: Text('Something went wrong'),
                    );
                  }
                  final revenueData = chatSnapshot.data!.docs;
                  double money = 0;
                  chatSnapshot.data!.docs.forEach((f) => money += f['money']);
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: const Color(0xff475e75),
                        padding: const EdgeInsets.all(8),
                        child: Text('Total revenue amount: \$${money.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ), textAlign: TextAlign.center,),
                      ),
                      Flexible(
                        child: ListView.builder(
                          itemCount: revenueData.length,
                          itemBuilder: (ctx, index) {
                            return Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: double.infinity,
                              child: ListTile(
                                title: Text('Booking created date: ${dateFormat.format(revenueData[index]['create_at'].toDate())}${revenueData[index]['time_range']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Patient: ${revenueData[index]['name_patient']}'),
                                    Text('Amount: \$${revenueData[index]['money'].toStringAsFixed(2)}'),
                                  ],
                                ),
                                tileColor: Colors.blue[50],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
