import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/account/create_account.dart';
import 'package:techwiz_5/ui/driver/dirvier_manager/create_admin_driver.dart';
import 'package:techwiz_5/ui/widgets/account_card.dart';
import 'package:techwiz_5/ui/widgets/driver_card.dart';

class DriverScreenAdmin extends StatefulWidget {
  const DriverScreenAdmin({super.key});

  @override
  State<DriverScreenAdmin> createState() => _DriverScreenAdminState();
}

class _DriverScreenAdminState extends State<DriverScreenAdmin> {
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('driver');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff223548),
      body: Container(
        margin: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: myItems.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              final items = streamSnapshot.data!.docs;
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = items[index];
                  return Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Container(
                      // borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: DriverCard(
                          account: documentSnapshot,
                        ),
                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const DriverFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
