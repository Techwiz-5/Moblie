import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techwiz_5/ui/admin/ambulance/create_ambulance.dart';
import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance_screen.dart';
import 'package:techwiz_5/ui/admin/booking/booking_detail.dart';
import 'package:techwiz_5/ui/user/hospital_detail_screen.dart';
import 'package:techwiz_5/ui/user/user_google_map_pickup.dart';
import 'package:techwiz_5/ui/widgets/ribbon.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
// import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance.dart';

class BookingCard extends StatefulWidget {
  const BookingCard({super.key, required this.booking});
  final dynamic booking;

  @override
  State<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
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
              //test
              EditAmbulanceScreen(ambulanceId: widget.booking['id']),
        ),
      );
    } else if (result == 'delete') {
      _showDialogConfirm();
    }
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

  String statusText(int status) {
    if (status == 0)
      return 'Pending';
    else if (status == 1) return 'Received';
    return 'Finish';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _fetchHospital();
  }

  // void _fetchHospital() async {
  //   DocumentSnapshot querySnapshot = await FirebaseFirestore.instance
  //       .collection('hospital')
  //       .doc(widget.ambulance['hospital_id'])
  //       .get();
  //   print(querySnapshot.toString());
  //   var ambulanceData = querySnapshot.data() as Map<String, dynamic>;
  //   setState(() {
  //     hospitalName = ambulanceData['name'];
  //     hospitalPhone = ambulanceData['phone'];
  //     hospitalAddress = ambulanceData['address'];
  //   });
  //   print(hospitalPhone);
  //   print(hospitalName);
  // }

  @override
  Widget build(BuildContext context) {
    // print(widget.ambulance['hospital_id']);
    return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.blue, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hiển thị thời gian
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    DateFormat('dd-MM-yyyy hh:mm').format(widget.booking['booking_time'].toDate()),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText(widget.booking['status']),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Address: ${widget.booking['address'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.person,
                color: Colors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Name Patient: ${widget.booking['name_patient'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.phone,
                color: Colors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Phone: ${widget.booking['phone_number'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Center(
          //   child: ElevatedButton(
          //     onPressed: () => Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => UserGoogleMapPickupPoint(
          //           bookingId: widget.booking['id'],
          //           driverLocationLat: double.parse(widget.booking["uptLat"]),
          //           driverLocationLong: double.parse(widget.booking["uptLng"]),
          //         ),
          //       ),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.blue[300],
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(20),
          //       ),
          //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          //       elevation: 3,
          //     ),
          //     child: const Text(
          //       "View Google Map",
          //       style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 10),
          // widget.booking['status'] == 0
          //     ? GestureDetector(
          //   onTap: _showDialogConfirm,
          //   child: const Icon(
          //     Icons.delete,
          //     color: Colors.redAccent,
          //   ),
          // )
          //     : const SizedBox.shrink(),
          ///here
          Center(
            child: Row(
              children: [
                Expanded(
                  flex: widget.booking['status'] == 0 ? 3 : 4,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserGoogleMapPickupPoint(
                          bookingId: widget.booking['id'],
                          driverLocationLat: double.parse(widget.booking["uptLat"].toString()),
                          driverLocationLong: double.parse(widget.booking["uptLng"].toString()),
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                    ),
                    child: const Text("View Google Map"),
                  ),
                ),
                if (widget.booking['status'] == 0) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _showDialogConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
    );
  }
}
