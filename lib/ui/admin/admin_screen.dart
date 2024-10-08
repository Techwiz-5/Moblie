import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/account_manager.dart';
import 'package:techwiz_5/ui/admin/ambulance/ambulance_screen.dart';
import 'package:techwiz_5/ui/admin/booking/booking_screen.dart';
import 'package:techwiz_5/ui/admin/feeedback/feedback_screen.dart';
import 'package:techwiz_5/ui/admin/revenue/revenue_screen.dart';
import 'package:techwiz_5/ui/driver/driver_page.dart';
import 'package:techwiz_5/ui/admin/hospital/hospital_screen.dart';
import 'package:techwiz_5/ui/driver/driver_screen.dart';
import 'package:techwiz_5/ui/widgets/booking_card.dart';
import 'package:techwiz_5/ui/widgets/feedback_card.dart';

import '../../utils/UserStatusService.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with WidgetsBindingObserver {
  int _pageIndex = 0;
  late UserStatusService _userStatusService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _userStatusService = UserStatusService();
    _userStatusService.monitorUserConnection();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  final List<Widget> pages = [
    const HospitalScreen(),
    const BookingScreen(),
    const AccountManagerScreen(),
    const FeedbackScreen(),
    const RevenueScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff223548),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.white38,
        selectedItemColor: Colors.white,
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(EneftyIcons.hospital_outline),
            activeIcon: Icon(EneftyIcons.hospital_bold),
            label: 'Hospital ',
          ),
          BottomNavigationBarItem(
            icon: Icon(EneftyIcons.ticket_outline),
            activeIcon: Icon(EneftyIcons.ticket_bold),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(EneftyIcons.profile_2user_outline),
            activeIcon: Icon(EneftyIcons.profile_2user_bold),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(EneftyIcons.message_2_outline),
            activeIcon: Icon(EneftyIcons.message_2_outline),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(EneftyIcons.dollar_circle_outline),
            activeIcon: Icon(EneftyIcons.dollar_circle_bold),
            label: 'Revenue',
          ),
        ],
      ),
    );
  }
}
