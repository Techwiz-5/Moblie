import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({super.key, required this.account});
  final dynamic account;

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('account');
  Future<void> _showPopupMenu(Offset offset) async {
    // double left = offset.dx;
    // double top = offset.dy;
    // final result = await showMenu<String>(
    //   context: context,
    //   position: RelativeRect.fromLTRB(left, top, left + 1, top + 1),
    //   items: [
    //     PopupMenuItem(
    //       value: 'edit',
    //       child: const Text('Edit'),
    //     ),
    //     PopupMenuItem(
    //       value: 'delete',
    //       child: const Text('Delete'),
    //     ),
    //   ],
    //   elevation: 8.0,
    // );

    // if (result == 'edit') {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) =>
    //           EditHospitalScreen(hospitalId: widget.hospital['id']),
    //     ),
    //   );
    // } else if (result == 'delete') {
    //   _showDialogConfirm();
    // }
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.account['email']);
    // print(widget.account['phone']);
    // print(widget.account['name']);
    // print(widget.account['uid']);

    return Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                left: BorderSide(
                  //                   <--- left side
                  color: Colors.blue,
                  width: 6.0,
                ),
                top: BorderSide(
                  //                    <--- top side
                  color: Colors.blue,
                  width: 1.0,
                ),
                right: BorderSide(
                  //                    <--- top side
                  color: Colors.blue,
                  width: 1.0,
                ),
                bottom: BorderSide(
                  //                    <--- top side
                  color: Colors.blue,
                  width: 1.0,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 0,
                  blurRadius: 10,
                ),
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            // backgroundColor:Colors.white
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: DecorationImage(
                              image: NetworkImage(widget.account['image']),
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50.0)),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Name : ${widget.account['name']}',
                              style: const TextStyle(
                                height: 2,
                                color: Colors.black,
                                // fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Phone : ${widget.account['phone']}',
                              style: const TextStyle(
                                // fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 12, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email : ${widget.account['email']}',
                      style: const TextStyle(
                        // fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      'Address : ${widget.account['address']}',
                      style: const TextStyle(
                        // fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              
            ],
          ),
        ));
  }
}
