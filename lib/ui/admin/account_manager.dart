import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/ui/admin/account/account_screen.dart';
import 'package:techwiz_5/ui/admin/account/create_account.dart';
import 'package:techwiz_5/ui/driver/dirvier_manager/driver_admin_screen.dart';
import 'package:techwiz_5/ui/driver/driver_screen.dart';

import '../../data/authentication.dart';
import '../login_screen.dart';

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
      backgroundColor: const Color(0xff475e75),
      appBar: AppBar(
        backgroundColor: const Color(0xff223548),
        centerTitle: true,
        title: const Text('Account Manager', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () async {
              await AuthServices().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(
              EneftyIcons.logout_2_outline,
              color: Colors.white,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white54,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'User Manager'),
            Tab(text: 'Driver Manager'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AccountScreen(),
          DriverScreenAdmin(),
        ],
      ),
    );
  }
}
