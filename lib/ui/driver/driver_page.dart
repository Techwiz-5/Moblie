import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/hospital/hospital_screen.dart';
import 'package:techwiz_5/ui/user/appointment_screen.dart';
import 'package:techwiz_5/ui/user/booking_screen.dart';
import 'package:techwiz_5/ui/user/profile/user_screen.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  int _pageIndex = 0;

  final List<Widget> pages = [
    const DriverScreen(),
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
            activeIcon: Icon(Icons.home, color: Colors.blue,),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person, color: Colors.blue,),
            label: 'User',
          ),
          ],
      ),
    );
  }
}
