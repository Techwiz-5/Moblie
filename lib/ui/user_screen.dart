import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/data/authentication.dart';
import 'package:techwiz_5/data/google_auth.dart';
import 'package:techwiz_5/ui/login_screen.dart';
import 'package:techwiz_5/ui/widgets/button.dart';

class UserScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UserScreen({required this.userData});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 90,
                  backgroundImage: NetworkImage(
                    FirebaseAuth.instance.currentUser!.photoURL ??
                        (widget.userData['image'] ??
                            'https://via.placeholder.com/150'),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            "UID: ${widget.userData['uid']}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "Email: ${widget.userData['email']}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "Name: ${widget.userData['name']}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            "Phone: ${widget.userData['phone']}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // MyButtons(
          //   onTap: () {
          //     Navigator.of(context).pushReplacement(
          //       MaterialPageRoute(builder: (context) => const EditScreen()),
          //     );
          //   },
          //   text: 'Edit',
          // ),
          // ElevatedButton(onPressed: () => FlutterPhoneDirectCaller.callNumber('+84949181836'), child: Text("Call")),
          MyButtons(
            onTap: () async {
              if (FirebaseAuth
                  .instance.currentUser!.providerData[0].providerId ==
                  'google.com') {
                await FirebaseServices().googleSignOut();
              } else {
                await AuthServices().logout();
              }
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            text: 'Log Out',
          ),
        ],
      ),
    );
  }
}
