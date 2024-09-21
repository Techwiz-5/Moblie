import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/hospital/hospital_screen.dart';
import 'package:techwiz_5/ui/driver/driver_screen.dart';
import 'package:techwiz_5/ui/user/appointment_screen.dart';
import 'package:techwiz_5/ui/user/booking_screen.dart';
import 'package:techwiz_5/ui/user/profile/user_screen.dart';

class DriverPage extends StatefulWidget {
  const DriverPage({super.key, required this.driverId});
  final String driverId;

  @override
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  int _pageIndex = 0;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      DriverScreen(
        driverId: widget.driverId,
      ),
      const ProfileScreen(),
    ];

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
      ),
    );
  }
}
