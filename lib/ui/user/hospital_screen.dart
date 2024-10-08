import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/user/search_screen.dart';
import 'package:techwiz_5/ui/widgets/hospital_card.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  final CollectionReference myItems = FirebaseFirestore.instance.collection('hospital');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.withOpacity(0.15),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Hospital',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          searchInput(),
          Flexible(
            child: StreamBuilder(
              stream: myItems.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No hospital found'),
                  );
                }
                if (streamSnapshot.hasData) {
                  final items = streamSnapshot.data!.docs;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot = items[index];
                      return HospitalCard(hospital: documentSnapshot,);
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
        ],
      ),
    );
  }

  Widget searchInput() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => const SearchScreen()));
          },
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(30),
                color: Colors.white
            ),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Text("Type keyword to search"),
                const Spacer(),
                Icon(
                  EneftyIcons.search_normal_2_outline,
                  size: 18,
                  color: Colors.grey[800],
                )
              ],
            ),
          ),
        )
    );
  }
}
