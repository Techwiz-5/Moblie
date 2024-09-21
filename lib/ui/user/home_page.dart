import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/ambulance/ambluance_libary.dart';
import 'package:techwiz_5/ui/user/appointment_screen.dart';
import 'package:techwiz_5/ui/user/profile/user_screen.dart';
import 'package:techwiz_5/ui/user/hospital_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> updateUserStatus(String userId, bool isOnline) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userDoc.exists) {
      Map<String, dynamic> userRole = userDoc.data() as Map<String, dynamic>;

      if (userRole['role'] == 'driver') {
        await FirebaseFirestore.instance.collection('drivers').doc(userId).update({
          'online': isOnline,
        });
      } else if (userRole['role'] == 'user') {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'online': isOnline,
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
        await updateUserStatus(user.uid, false);
      } else if (state == AppLifecycleState.resumed) {
        await updateUserStatus(user.uid, true);
      }
    }
  }

  final List<Widget> pages = [
    const HospitalScreen(),
    const AppointmentScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(
              Icons.home,
              color: Colors.blue,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            activeIcon: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(width: 4.0, color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.call)),
            ),
            icon: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(width: 4.0, color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.call),
              ),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(
              Icons.person,
              color: Colors.blue,
            ),
            label: 'User',
          ),
          // const BottomNavigationBarItem(
          //   icon: Icon(Icons.fire_truck),
          //   activeIcon: Icon(
          //     Icons.fire_truck,
          //     color: Colors.blue,
          //   ),
          //   label: 'User',
          // ),
        ],
      ),
    );
  }
}
