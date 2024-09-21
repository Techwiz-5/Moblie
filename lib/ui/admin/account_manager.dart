import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/account/account_screen.dart';
import 'package:techwiz_5/ui/admin/account/create_account.dart';
import 'package:techwiz_5/ui/driver/dirvier_manager/driver_admin_screen.dart';
import 'package:techwiz_5/ui/driver/driver_screen.dart';

class AccountManagerScreen extends StatefulWidget {
  const AccountManagerScreen({super.key});

  @override
  State<AccountManagerScreen> createState() => _AccountManagerScreenState();
}

class _AccountManagerScreenState extends State<AccountManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formSearchMain = GlobalKey<FormState>();
  int indexTab = 0;
  List jobsData = [];
  List companyData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {
      indexTab = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 241, 242, 243),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text('Account Manager', style: TextStyle(color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Expanded(
              child: Tab(text: 'User Manager'),
            ),
            Expanded(
              child: Tab(text: 'Driver Manager'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AccountScreen(),
          DriverScreenAdmin(),
        ],
      ),
    );
  }
}
