import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>{
  final _formSearchMain = GlobalKey<FormState>();
  String _keyword = '';

  search(String value) async {
    final isValid = _formSearchMain.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formSearchMain.currentState!.save();
  }

  onGoBack(dynamic value) {
    setState(() {});
  }

  Container noResult() {
    return Container(
      alignment: Alignment.topCenter,
        margin: const EdgeInsets.symmetric(vertical: 30),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: const Text('Sorry we did not found any result,\n please try other keyword', style: TextStyle(
          color: Colors.black45
        ), textAlign: TextAlign.center,)
    );
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
                  hintText: _keyword,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                autofocus: true,
                onFieldSubmitted: (value) async {
                  _keyword = value;
                  await search(value);
                },
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          body: Text("hospital")),
    );
  }
}
