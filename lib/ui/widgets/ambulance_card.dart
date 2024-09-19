import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/ambulance/create_ambulance.dart';
import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance_screen.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
// import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance.dart';

class AmbulanceCard extends StatefulWidget {
  const AmbulanceCard({super.key, required this.ambulance});
  final dynamic ambulance;

  @override
  State<AmbulanceCard> createState() => _AmbulanceCardState();
}

class _AmbulanceCardState extends State<AmbulanceCard> {
  Future<void> _deleteOldImageFromFirebase(String oldImageUrl) async {
    try {
      final Reference oldImgRef =
      FirebaseStorage.instance.refFromURL(oldImageUrl);
      await oldImgRef.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Center(
                child: Stack(
              alignment: Alignment.bottomLeft,
              children: <Widget>[
                Image.network(
                  widget.ambulance['image'],
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ],
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(0.5),
            child: Card(
              color: Colors.white,
              borderOnForeground: false,
              shadowColor: Colors.white,
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plate Number : ${widget.ambulance['plate_number']} ',
                      style: const TextStyle(
                        height: 2,
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Type : ${widget.ambulance['type']} ',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      'Enable : ${widget.ambulance['enable'] == 0 ? 'Yes' : 'No'} ',
                      style: const TextStyle(
                        height: 1.5,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 1,
                      child: ListTile(
                        title: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10, left: 10),
                            ),
                            Expanded(
                              child: Text('Edit'),
                            ),
                            Icon(Icons.edit),
                          ],
                        ),
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditAmbulanceScreen(
                                      ambulanceId: widget.ambulance['id'],
                                      ),
                            ),
                          )
                        },
                      ),
                    ),
                    PopupMenuItem(
                      // padding: EdgeInsets.all(10),
                      value: 2,
                      child: ListTile(
                        title: const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10, left: 10),
                            ),
                            Expanded(
                              child: Text('Delete'),
                            ),
                            Icon(Icons.delete),
                          ],
                        ),
                        onTap: () async {
                          await FirebaseFirestore.instance.collection('ambulance').doc(widget.ambulance['id']).delete();
                          await _deleteOldImageFromFirebase(widget.ambulance['image']);
                          showSnackBar(context, 'Delete successfully');
                          setState(() {

                          });
                        },
                      ),
                    )
                  ],
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ),
            ),
          )
        ],
      ),
    );
    ;
  }
}
