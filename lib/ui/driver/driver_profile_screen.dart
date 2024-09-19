// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:techwiz_5/data/authentication.dart';
// import 'package:techwiz_5/ui/login_screen.dart';
// import 'package:techwiz_5/ui/user/profile/edit_profile_screen.dart';
//
// class DriverProfileScreen extends StatefulWidget {
//   const DriverProfileScreen({super.key});
//
//   @override
//   State<DriverProfileScreen> createState() => _DriverProfileScreenState();
// }
//
// class _DriverProfileScreenState extends State<DriverProfileScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? imageUrl;
//   late String _name;
//   late String _email = '';
//   late String _phone;
//   late String _address;
//
//   @override
//   void initState() {
//     super.initState();
//     getUserData();
//   }
//
//   void getUserData() async {
//     try {
//       DocumentSnapshot docSnapshot = await _firestore
//           .collection('account')
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .get();
//       if (docSnapshot.exists) {
//         var userData = docSnapshot.data() as Map<String, dynamic>;
//         setState(() {
//           _name = userData['name'];
//           _email = userData['email'];
//           _phone = userData['phone'];
//           _address = userData['address'];
//           imageUrl = userData['image'];
//         });
//       } else {
//         print('No data found for this user');
//       }
//     } catch (e) {
//       print('Error fetching user data: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue.withOpacity(0.15),
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: const Text(
//           'My Profile',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () async {
//               await AuthServices().logout();
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(builder: (context) => const LoginScreen()),
//               );
//             },
//             icon: const Icon(
//               Icons.exit_to_app_rounded,
//               color: Colors.white,
//             ),
//           ),
//         ],
//         leading: IconButton(
//           onPressed: () async {
//             bool? result = await Navigator.of(context).push(
//               MaterialPageRoute(
//                 builder: (context) => EditProfileScreen(
//                   hospitalId: FirebaseAuth.instance.currentUser!.uid,
//                 ),
//               ),
//             );
//             if (result == true) {
//               // Profile was updated, refresh the data
//               getUserData();
//             }
//           },
//           icon: const Icon(
//             Icons.edit,
//             color: Colors.white,
//           ),
//         ),
//       ),
//       body: (_email.isEmpty)
//           ? const Center(
//         child: CircularProgressIndicator(),
//       )
//           : SingleChildScrollView(
//         child: Column(
//           children: [
//             Stack(
//               children: [
//                 Card(
//                   elevation: 0,
//                   color: Colors.white,
//                   margin:
//                   const EdgeInsets.only(top: 60, left: 10, right: 10),
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 70),
//                           SizedBox(
//                             width: double.infinity,
//                             child: Text(
//                               _name,
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: double.infinity,
//                   margin: const EdgeInsets.only(top: 15),
//                   child: CircleAvatar(
//                     radius: 52,
//                     backgroundColor: Colors.grey.withOpacity(0.5),
//                     child: CircleAvatar(
//                         radius: 48,
//                         backgroundColor: Colors.white,
//                         child: CircleAvatar(
//                           backgroundImage: NetworkImage(imageUrl ??
//                               'https://via.placeholder.com/150'),
//                           radius: 44,
//                         )),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             myAction(),
//           ],
//         ),
//       ),
//     );
//   }
// }
