import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/data/authentication.dart';
import 'package:techwiz_5/ui/admin/account/create_account.dart';
import 'package:techwiz_5/ui/admin/ambulance/create_ambulance.dart';
import 'package:techwiz_5/ui/login_screen.dart';
import 'package:techwiz_5/ui/widgets/account_card.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('account');
  @override
  Widget build(BuildContext context) {
    print(myItems);
    return Scaffold(
      body: StreamBuilder(
        stream: myItems.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            final items = streamSnapshot.data!.docs;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                print(index);
                final DocumentSnapshot documentSnapshot = items[index];
                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    // borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: AccountCard(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AccountFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
