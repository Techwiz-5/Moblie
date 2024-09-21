// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class DriverBookingDetailScreen extends StatefulWidget {
//   const DriverBookingDetailScreen({super.key, required this.driverId});
//   final String driverId;

//   @override
//   State<DriverBookingDetailScreen> createState() =>
//       _DriverBookingDetailScreenState();
// }

// class _DriverBookingDetailScreenState extends State<DriverBookingDetailScreen> {
//   late String _id = '';
//   late String _booking_time;
//   late String _status;
//   late String _plate_number;
//   @override
//   void initState() {
//     super.initState();
//     getData();
//     print(widget.driverId);
//     print(_id);
//   }

//   getData() async {
//     try {
//       QuerySnapshot driversSnapshot = await FirebaseFirestore.instance
//           .collection('booking')
//           .where('driver_id', isEqualTo: widget.driverId)
//           .get()
//           .then((driver) {
//         setState(() {
//           // _id = driver['id'];
//           // _booking_time = driver['booking_time'];
//           // _status = driver['status'];
//           // _selectedHospital = doc['hospital_id'];
//           // _hospitals = querySnapshot.docs.map((doc) {
//           //   return {'id': doc.id, 'name': doc['name']};
//           // }).toList();
//           print(_id);
//           print(_status);
//         });
//       });
//       // driversSnapshot.docs.map((doc) {
//       //   setState(() {
//       //     _id = doc['id'];
//       //     _booking_time = doc['booking_time'];
//       //     _status = doc['status'];
//       //     // _selectedHospital = doc['hospital_id'];
//       //     // _hospitals = querySnapshot.docs.map((doc) {
//       //     //   return {'id': doc.id, 'name': doc['name']};
//       //     // }).toList();
//       //     print(_id);
//       //     print(_status);
//       //   });
//       //   print(_id);
//       //   print(_status);
//       // });
//     } catch (e) {
//       print('Error fetching ambulance data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.blue,
//         surfaceTintColor: Colors.blue,
//         title: const Text(
//           'Booking Detail',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Padding(
//             padding: EdgeInsets.all(10.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       //  ${widget.driversSnapshot['address']}
//                       '${_id ?? 'None'}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                       ),
//                     ),
//                     const SizedBox(
//                       width: 10,
//                     ),
//                     Icon(
//                       Icons.info_outline,
//                       color: Colors.red,
//                     )
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
