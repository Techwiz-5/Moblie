import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/data/notification.dart';
import 'package:techwiz_5/ui/admin/hospital/hospital_screen.dart';
import 'package:techwiz_5/ui/driver/accessBooking.dart';
import 'package:techwiz_5/ui/driver/driver_profile_screen.dart';
import 'package:techwiz_5/ui/driver/driver_screen.dart';
import 'package:techwiz_5/ui/user/profile/user_screen.dart';

import '../../utils/UserStatusService.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key, required this.driverId});

  final String driverId;

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> with WidgetsBindingObserver {
  late UserStatusService _userStatusService;

  @override
  void initState() {
    super.initState();
    getUserData();
    try {
      FirebaseMessaging.onMessage.listen((event) async {
        
        NotiService().showNotification(event);
        
        if (event.notification!.body != null) {
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccessBooking(
                driverId: widget.driverId,bookingId: event.notification!.body.toString(),
              ),
            ),
          );
        }
      });
    } catch (e) {}
    _userStatusService = UserStatusService();
    _userStatusService.monitorUserConnection();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _pageIndex = 0;
  String _role = '';
  var isLoading = true;

  void notificationHander(driverId) {
    FirebaseMessaging.onMessage.listen((event) async {
      print(event.notification!.title);
      NotiService().showNotification(event);
      if (event.notification!.body != null) {
      }
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
      const DriverProfileScreen(),
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
