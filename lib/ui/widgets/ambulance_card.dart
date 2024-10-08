import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  String? hospitalName;
  String? hospitalPhone;
  String? hospitalAddress;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late int _availableSlot;
  String _role = '';

  void getUserData() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot docSnapshot;

      docSnapshot = await _firestore.collection('account').doc(uid).get();
      if (!docSnapshot.exists) {
        docSnapshot = await _firestore.collection('driver').doc(uid).get();
      }
      var userData = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _role = userData['role'];
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(left, top, left + 1, top + 1),
      items: [
        const PopupMenuItem(
          value: 'edit',
          child: const Text('Edit'),
        ),
        const PopupMenuItem(
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
      getDataHospital();
      _showDialogConfirm();
    }
  }

  _onDelete() async {
    await _editHospital();
    await FirebaseFirestore.instance
        .collection('ambulance')
        .doc(widget.ambulance['id'])
        .delete();
    await _deleteOldImageFromFirebase(widget.ambulance['image']);
  }

  void getDataHospital() async {
    try {
      DocumentSnapshot docSnapshot = await _firestore
          .collection('hospital')
          .doc(widget.ambulance['hospital_id'])
          .get();
      if (docSnapshot.exists) {
        var hospitalData = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _availableSlot = hospitalData['availableSlot'];
        });
      } else {
        print('No data found for this hospital');
      }
    } catch (e) {
      print('Error fetching hospital data: $e');
    }
  }

  _editHospital() async {
    try {
      await _firestore
          .collection('hospital')
          .doc(widget.ambulance['hospital_id'])
          .update({
        'availableSlot': _availableSlot - 1,
      });
    } on FirebaseException catch (e) {
      showSnackBar(context, e.toString());
    }
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchHospital();
    getUserData();
  }

  void _fetchHospital() async {
    DocumentSnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('hospital')
        .doc(widget.ambulance['hospital_id'])
        .get();
    print(querySnapshot.toString());
    var ambulanceData = querySnapshot.data() as Map<String, dynamic>;
    setState(() {
      hospitalName = ambulanceData['name'];
      hospitalPhone = ambulanceData['phone'];
      hospitalAddress = ambulanceData['address'];
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.ambulance['hospital_id']);
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 9,
                          child: Text(
                            'Hospital Name: ${hospitalName} ',
                            style: const TextStyle(
                              // height: 2,
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // const Spacer(),
                        if (_role == 'admin')
                          Flexible(
                            child: GestureDetector(
                              onTapDown: (TapDownDetails details) async {
                                await _showPopupMenu(details.globalPosition);
                              },
                              child: const Icon(Icons.more_vert_rounded),
                            ),
                          )
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          size: 18,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Phone: ${hospitalPhone} ',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_bus,
                          size: 18,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Type:',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Badge(
                          label: Text('${widget.ambulance['type']}'),
                          backgroundColor: Colors.blue[500],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.info,
                          size: 18,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Plate Number: ${widget.ambulance['plate_number']} ',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user,
                          size: 18,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Status: ${widget.ambulance['enable'] == 0 ? 'Enable' : 'Disable'} ',
                          style: const TextStyle(
                            height: 1.5,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
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
