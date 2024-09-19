import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/ambulance/create_ambulance.dart';
import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance_screen.dart';
import 'package:techwiz_5/ui/widgets/ribbon.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
// import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance.dart';

class AmbulanceCard extends StatefulWidget {
  const AmbulanceCard({super.key, required this.ambulance});
  final dynamic ambulance;

  @override
  State<AmbulanceCard> createState() => _AmbulanceCardState();
}

class _AmbulanceCardState extends State<AmbulanceCard> {
  Future<void> _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(left, top, left + 1, top + 1),
      items: [
        PopupMenuItem(
          value: 'edit',
          child: const Text('Edit'),
        ),
        PopupMenuItem(
          value: 'delete',
          child: const Text('Delete'),
        ),
      ],
      elevation: 8.0,
    );

    if (result == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditAmbulanceScreen(ambulanceId: widget.ambulance['id']),
        ),
      );
    } else if (result == 'delete') {
      _showDialogConfirm();
    }
  }

  _onDelete() async {
    await FirebaseFirestore.instance
        .collection('ambulance')
        .doc(widget.ambulance['id'])
        .delete();
    await _deleteOldImageFromFirebase(widget.ambulance['image']);
  }

  Future<void> _deleteOldImageFromFirebase(String oldImageUrl) async {
    try {
      final Reference oldImgRef =
          FirebaseStorage.instance.refFromURL(oldImageUrl);
      await oldImgRef.delete();
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> _showDialogConfirm() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Are you sure you want to delete?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              onPressed: () {
                _onDelete();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            )
          ],
        );
      },
    );
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
          Stack(
            children: <Widget>[
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
                  ),
                ),
              ),
              Container(
                child: ClipPath(
                  clipper: ArcClipper(),
                  child: Container(
                    width: 200,
                    height: 40.0,
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.lightBlue,
                    child: Text(
                      '${widget.ambulance['hospital']}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                  ),
                ),
              ),
            ],
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
                trailing: GestureDetector(
                  onTapDown: (TapDownDetails details) async {
                    await _showPopupMenu(details.globalPosition);
                  },
                  child: const Icon(Icons.more_vert_rounded),
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
