import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/user/booking_screen.dart';
import 'package:techwiz_5/ui/user/user_screen.dart';
import 'package:techwiz_5/ui/user/hospital_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('hospital');
  bool isSearch = false;
  int _pageIndex = 0;

  final List<Widget> pages = [
    const HospitalScreen(),
    const BookingScreen(),
    const AccountScreen(),
    const BookingScreen(),
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
            icon: Icon(Icons.bookmark_added),
            activeIcon: Icon(Icons.bookmark_added, color: Colors.blue,),
            label: 'Booking',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person, color: Colors.blue,),
            label: 'User',
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
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.call)

              ),
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
                      offset:
                      const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.call),
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}