import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/hospital_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _formSearchMain = GlobalKey<FormState>();
  String _keyword = '';
  List<DocumentSnapshot> allHospitals = [];
  List<DocumentSnapshot> searchResults = [];

  @override
  void initState() {
    super.initState();
    fetchHospitals();
  }

  fetchHospitals() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('hospital').get();
    setState(() {
      allHospitals = querySnapshot.docs;
      searchResults = allHospitals;
    });
  }

  search(String value) {
    setState(() {
      _keyword = value.toLowerCase();
      if (_keyword.isEmpty) {
        searchResults = allHospitals;
      } else {
        searchResults = allHospitals.where((doc) {
          String hospitalName = doc['name'].toString().toLowerCase();
          return hospitalName.contains(_keyword);
        }).toList();
      }
    });
  }

  Container noResult() {
    return Container(
        alignment: Alignment.topCenter,
        margin: const EdgeInsets.symmetric(vertical: 30),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: const Text(
          'Sorry, we did not find any result,\n please try another keyword',
          style: TextStyle(color: Colors.black45),
          textAlign: TextAlign.center,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 241, 242, 243),
          appBar: AppBar(
            backgroundColor: Colors.blue,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Form(
              key: _formSearchMain,
              child: TextFormField(
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  hintText: 'Search by name',
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                autofocus: true,
                onChanged: (value) {
                  search(value);
                },
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          body: Column(
            children: [
              Flexible(
                child: searchResults.isEmpty
                    ? noResult()
                    : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                    searchResults[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: HospitalCard(
                        hospital: documentSnapshot,
                      ),
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
