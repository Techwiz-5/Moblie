import 'package:flutter/material.dart';
import 'package:techwiz_5/data/authentication.dart';
import 'package:techwiz_5/ui/admin/driver_screen.dart';
import 'package:techwiz_5/ui/admin/hospital_screen.dart';
import 'package:techwiz_5/ui/login_screen.dart';
import 'package:techwiz_5/ui/widgets/button.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key, required this.userData});
  final dynamic userData;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _pageIndex = 0;

  final List<Widget> pages = [
    const HospitalScreen(),
    const DriverScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Hospital',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.drive_eta),
            label: 'Driver',
          ),
        ],
      ),
    );
  }
}
