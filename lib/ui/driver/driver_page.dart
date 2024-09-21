import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/data/notification.dart';
import 'package:techwiz_5/ui/admin/hospital/hospital_screen.dart';
import 'package:techwiz_5/ui/driver/driver_screen.dart';
import 'package:techwiz_5/ui/user/profile/user_screen.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key, required this.driverId});
  final String driverId;

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUserData();
    notificationHander();
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _pageIndex = 0;
  String _role = '';
  var isLoading = true;

  void notificationHander(){
    FirebaseMessaging.onMessage.listen((event) async {
      print(event.notification!.title);
      NotiService().showNotification(event);
    });
  }


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
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DriverScreen(
        driverId: widget.driverId,
        roleCurrent: _role,
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : pages[_pageIndex],
        bottomNavigationBar: (_role == 'driver')
            ? BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _pageIndex,
                onTap: (value) {
                  setState(() {
                    _pageIndex = value;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    activeIcon: Icon(
                      Icons.home,
                      color: Colors.blue,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    activeIcon: Icon(
                      Icons.person,
                      color: Colors.blue,
                    ),
                    label: 'User',
                  ),
                ],
              )
            : null);
  }
}
