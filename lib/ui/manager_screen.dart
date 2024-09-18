import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/data/authentication.dart';
import 'package:techwiz_5/data/google_auth.dart';
import 'package:techwiz_5/ui/login_screen.dart';
import 'package:techwiz_5/ui/widgets/button.dart';

class ManagerScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ManagerScreen({required this.userData});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
              MaterialPageRoute(
                  builder: (context) => const LoginScreen()),
            );
          },
          text: 'Log Out',
        ),
        Image.network(
          "${FirebaseAuth.instance.currentUser!.photoURL}",
          width: 35,
        ),
        Text("UID: ${widget.userData['uid']}"),
        Text("Email: ${widget.userData['email']}"),
        Text("Name: ${widget.userData['name']}"),
        Text("Role: ${widget.userData['role']}"),
        // MyButtons(
        //   onTap: () {
        //     Navigator.of(context).pushReplacement(
        //       MaterialPageRoute(builder: (context) => const EditScreen()),
        //     );
        //   },
        //   text: 'Edit',
        // ),
        // ElevatedButton(onPressed: () => FlutterPhoneDirectCaller.callNumber('+84949181836'), child: Text("Call")),
      ],
    );
  }
}
