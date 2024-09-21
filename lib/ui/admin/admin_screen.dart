import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/account_manager.dart';
import 'package:techwiz_5/ui/admin/ambulance/ambulance_screen.dart';
import 'package:techwiz_5/ui/admin/booking/booking_screen.dart';
import 'package:techwiz_5/ui/admin/revenue/revenue_screen.dart';
import 'package:techwiz_5/ui/driver/driver_page.dart';
import 'package:techwiz_5/ui/admin/hospital/hospital_screen.dart';
import 'package:techwiz_5/ui/driver/driver_screen.dart';
import 'package:techwiz_5/ui/widgets/booking_card.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with WidgetsBindingObserver{
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
    const BookingScreen(),
    const AccountManagerScreen(),
    const RevenueScreen(),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Hospital ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online_rounded),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Revenue',
          ),
        ],
      ),
    );
  }
}
