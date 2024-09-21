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

class _AdminScreenState extends State<AdminScreen> {
  int _pageIndex = 0;

  final List<Widget> pages = [
    const HospitalScreen(),
    const AmbulanceScreen(),
    const BookingScreen(),
    const RevenueScreen(),
    const AccountManagerScreen(),
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
            label: 'Hospital',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital_rounded),
            label: 'Ambulance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online_rounded),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Revenue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
