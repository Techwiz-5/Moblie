import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/ambulance/create_ambulance.dart';
import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance_screen.dart';
import 'package:techwiz_5/ui/user/hospital_detail_screen.dart';
import 'package:techwiz_5/ui/widgets/ribbon.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
// import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance.dart';

class AdminBookingDetailScreen extends StatefulWidget {
  const AdminBookingDetailScreen({super.key, required this.booking});
  final dynamic booking;

  @override
  State<AdminBookingDetailScreen> createState() =>
      _AdminBookingDetailScreenState();
}

class _AdminBookingDetailScreenState extends State<AdminBookingDetailScreen> {
  Future<void> _showPopupMenu(Offset offset) async {
    // double left = offset.dx;
    // double top = offset.dy;
    // final result = await showMenu<String>(
    //   context: context,
    //   position: RelativeRect.fromLTRB(left, top, left + 1, top + 1),
    //   items: [
    //     const PopupMenuItem(
    //       value: 'edit',
    //       child: const Text('Edit'),
    //     ),
    //     const PopupMenuItem(
    //       value: 'delete',
    //       child: const Text('Delete'),
    //     ),
    //   ],
    //   elevation: 8.0,
    // );

    // if (result == 'edit') {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) =>
    //           //test
    //           EditAmbulanceScreen(ambulanceId: widget.booking['id']),
    //     ),
    //   );
    // } else if (result == 'delete') {
    //   _showDialogConfirm();
    // }
  }

  _onDelete() async {
    await FirebaseFirestore.instance
        .collection('booking')
        .doc(widget.booking['id'])
        .delete();
    await _deleteOldImageFromFirebase(widget.booking['image']);
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

  // Future<void> _showDialogConfirm() async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text(
  //           'Are you sure you want to delete?',
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Cancel'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               _onDelete();
  //               Navigator.of(context).pop();
  //             },
  //             child: Text(
  //               'Delete',
  //               style: TextStyle(color: Colors.white),
  //             ),
  //             style:
  //                 ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _fetchHospital();
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.ambulance['hospital_id']);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue,
        surfaceTintColor: Colors.blue,
        title: const Text(
          'Booking Detail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'Hospital Name : ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.info_outline,
                      color: Colors.red,
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
