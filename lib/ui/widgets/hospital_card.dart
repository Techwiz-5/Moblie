import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:techwiz_5/ui/admin/hospital/edit_hospital_screen.dart';
import 'package:techwiz_5/ui/user/hospital_detail_screen.dart';
import 'package:techwiz_5/ui/user/hospital_gallery_screen.dart';

import '../admin/ambulance/amabulance.dart';

class HospitalCard extends StatefulWidget {
  const HospitalCard({super.key, required this.hospital});
  final dynamic hospital;

  @override
  State<HospitalCard> createState() => _HospitalCardState();
}

class _HospitalCardState extends State<HospitalCard> {
  bool isAdmin = false;
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('hospital');

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('account')
          .doc(user.uid)
          .get();
      setState(() {
        isAdmin = userDoc.get('role') == 'admin';
      });
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
          child: Text('Edit'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
      ],
      elevation: 8.0,
    );

    if (result == 'edit') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EditHospitalScreen(hospitalId: widget.hospital['id']),
        ),
      );
    } else if (result == 'delete') {
      _showDialogConfirm();
    }
  }

  _onDelete() async {
    await FirebaseFirestore.instance
        .collection('hospital')
        .doc(widget.hospital['id'])
        .delete();
    await _deleteOldImageFromFirebase(widget.hospital['image']);
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
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
            child: Center(
                child: Stack(
              alignment: Alignment.bottomLeft,
              children: <Widget>[
                Image.network(
                  widget.hospital['image'] ?? '',
                  width: 150,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ],
            )),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          widget.hospital['name'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (isAdmin)
                        GestureDetector(
                          onTapDown: (TapDownDetails details) async {
                            await _showPopupMenu(details.globalPosition);
                          },
                          child: const Icon(Icons.more_vert_rounded),
                        ),
                    ],
                  ),
                  Text(
                    widget.hospital['description'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 92, 91, 91),
                        size: 20,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Flexible(
                        child: Text(
                          widget.hospital['address'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money_outlined,
                        color: Color.fromARGB(255, 92, 91, 91),
                        size: 20,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        '${widget.hospital['price'].toString()}/km',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(
                        color: Colors.blue,
                        width: 1.0,
                      ),)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () =>  {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AmabulanceOfHospitalScreen(
                                  hospital_id: widget.hospital['id'],
                                  hospital_name: widget.hospital['name'],
                                ),
                              ),
                            ),
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100]),
                          icon: const Icon(Icons.directions_bus),
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HospitalGalleryScreen(hospital: widget.hospital),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100]),
                          icon: const Icon(Icons.photo),
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HospitalDetailScreen(hospital: widget.hospital),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100]),
                          icon: const Icon(Icons.map),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
