import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:techwiz_5/ui/admin/ambulance/create_ambulance.dart';
import 'package:techwiz_5/ui/admin/ambulance/edit_ambulance_screen.dart';
import 'package:techwiz_5/ui/admin/booking/booking_detail.dart';
import 'package:techwiz_5/ui/user/hospital_detail_screen.dart';
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
              child: Text(
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

  String statusText (int status){
    if(status == 0) return 'Pending';
    else if(status == 1) return 'Running';
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
      margin: const EdgeInsets.symmetric(horizontal: 2),
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
          Padding(
            padding: const EdgeInsets.only(right: 0.5, left: 0.5),
            child: Card(
              color: Colors.white,
              borderOnForeground: false,
              shadowColor: Colors.white,
              child: ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('dd-MM-yyyy hh:mm').format(widget.booking['booking_time'].toDate()),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Badge(
                            label: Text(statusText(widget.booking['status'])),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color.fromARGB(255, 147, 148, 148),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            'Address: ${widget.booking['address'] ?? ''}',
                            // maxLines: ,
                            // overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.accessible_rounded,
                          color: Color.fromARGB(255, 147, 148, 148),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            'Name Patient: ${widget.booking['name_patient'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: Color.fromARGB(255, 147, 148, 148),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            'Phone: ${widget.booking['phone_number'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminBookingDetailScreen(
                                  booking: widget.booking),
                            ),
                          ),
                          child: const Text("View detail"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100]),
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: (widget.booking['status'] == 0) ? GestureDetector(
                  onTap: _showDialogConfirm,
                  child: const Icon(Icons.delete, color: Colors.red,),
                ) : null
              ),
            ),
          )
        ],
      ),
    );
    ;
  }
}
