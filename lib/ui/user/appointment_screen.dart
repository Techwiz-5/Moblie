import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:techwiz_5/data/notification.dart';
import 'package:techwiz_5/ui/user/home_page.dart';
import 'package:techwiz_5/ui/widgets/location_input.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';

import '../widgets/MapSearchAndPick.dart';
import 'hospital_select_card.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateFormat dateFormat = DateFormat("dd-MM-yyyy");
  double latitude = 0.0;
  double longitude = 0.0;
  bool isLoading = true;
  bool _showError = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _phoneController = TextEditingController();

  final CollectionReference _hospitalsCollection =
      FirebaseFirestore.instance.collection('hospital');
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('booking');
  final _formKeyAmbulance = GlobalKey<FormState>();
  String _namePatient = '';
  String _address = '';
  String _zipCode = '';
  String _phoneNumber = '';
  int _ambulanceType = 0;
  String _timeRange = 'am';
  List<Map<String, dynamic>> _hospitals = [];
  DateTime selectedDate = DateTime.now();
  LatLng? _selectedLocation;
  dynamic selectHospital;
  double money = 0;
  var isEmergency = false;
  List bookedAmbulance = [];
  List lstAmbulance = [];
  String plate_number = '';

  @override
  void initState() {
    super.initState();
    setupPushNotification();
    getPhone();
  }

  getPhone() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot docSnapshot;

      docSnapshot = await _firestore.collection('account').doc(uid).get();

      if (!docSnapshot.exists) {
        docSnapshot = await _firestore.collection('driver').doc(uid).get();
      }

      if (docSnapshot.exists) {
        var userData = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _phoneNumber = userData['phone'];
          _phoneController.text = _phoneNumber;
        });
      } else {
        showSnackBar(context, 'User does not exist in both collections');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  getAllAmbulance() async {
    QuerySnapshot querySnapshot = await myItems
        .where('hospital_id', isEqualTo: selectHospital['id'])
        .get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    setState(() {
      lstAmbulance = allData;
    });
  }

  getBookedSlot() async {
    DateTime bkgDate = selectedDate;
    var fromDate = DateTime(bkgDate.year, bkgDate.month, bkgDate.day);
    var toDate = DateTime(bkgDate.year, bkgDate.month, bkgDate.day + 1);
    QuerySnapshot querySnapshot = await myItems
        .where('hospital_id', isEqualTo: selectHospital['id'])
        .where('booking_time', isGreaterThanOrEqualTo: fromDate)
        .where('booking_time', isLessThan: toDate)
        .where('time_range', isEqualTo: _timeRange)
        .get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    setState(() {
      bookedAmbulance = allData;
    });
  }

  void getAmbulancePlate() {
    String rs = '';
    List bkgedAmbulance = [];
    List avaiAmbulance = [];
    for (var dt in bookedAmbulance) {
      bkgedAmbulance.add(dt['plate_number']);
    }
    for (var dt in lstAmbulance) {
      avaiAmbulance.add(dt['plate_number']);
    }

    for (var dt in avaiAmbulance) {
      if (!bkgedAmbulance.contains(dt)) {
        rs = dt;
        break;
      }
    }
    setState(() {
      plate_number = rs;
    });
    print(plate_number);
  }

  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;

    final notificationSettings = await fcm.requestPermission();

    final token = await fcm.getToken();

    fcm.subscribeToTopic('booking');
  }

  _createBooking() async {
    if (_selectedLocation == null || _address == null || _address!.isEmpty) {
      setState(() {
        _showError = true;
      });
      return;
    } else {
      setState(() {
        _showError = false;
      });
    }

    final isValid = _formKeyAmbulance.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKeyAmbulance.currentState!.save();
    try {
      DocumentReference docRef = await myItems.add({
        'name_patient': _namePatient,
        'address': _address,
        'zip_code': _zipCode,
        'phone_number': _phoneNumber,
        'ambulance_id': '',
        'ambulance_type': _ambulanceType,
        'hospital_id': selectHospital['id'],
        'status': 0,
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'urgent': 0,
        'create_at': DateTime.now(),
        'booking_time': selectedDate,
        'time_range': _timeRange,
        'driver_id': '',
        'plate_number': plate_number,
        'latitude': _selectedLocation!.latitude.toString(),
        'longitude': _selectedLocation!.longitude.toString(),
        'money': money,
        'uptLat': 0.0,
        'uptLng': 0.0
      });
      await docRef.update({
        'id': docRef.id,
      });
      await sendNotificationToDrivers(docRef.id);
    } on FirebaseException catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<String>> _fetchInactiveDriversTokens() async {
    List<String> driverTokens = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('driver')
          .where('enable', isEqualTo: 0)
          .get();

      for (var doc in querySnapshot.docs) {
        driverTokens.add(doc['fcm_token']);
      }
    } catch (e) {
      print('Error fetching drivers: $e');
    }
    return driverTokens;
  }

  Future<void> sendNotificationToDrivers(String bookingId) async {
    List<String> driverTokens = await _fetchInactiveDriversTokens();

    for (String token in driverTokens) {
      await NotiService()
          .pushNotifications(title: 'Test ', body: "Test body", token: token);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  onGoBack() async {
    await getAllAmbulance();
    await getBookedSlot();
    getAmbulancePlate();
    setState(() {});
  }

  double totalMoney(var hospital) {
    double stress1 = isEmergency ? 0.2 : 0;
    if (selectHospital != null) {
      double mn = (selectHospital['distance'] * selectHospital['price']);
      mn = mn + mn * stress1;
      return mn;
    }
    return 0;
  }

  void setEmergencyBooking() {
    setState(() {
      _address = '';
      isEmergency = !isEmergency;
    });
  }

  Future<void> _showDialogConfirm() async {
    return showModalBottomSheet(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Confirm information"),
            centerTitle: true,
          ),
          body: Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color.fromARGB(255, 92, 91, 91),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        _address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.local_hospital,
                      color: Color.fromARGB(255, 92, 91, 91),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        selectHospital['name'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.date_range,
                      color: Color.fromARGB(255, 92, 91, 91),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        dateFormat.format(selectedDate),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ]),
                    margin: EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'images/pngwing.png',
                            width: 60,
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Basic Life Saver',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'This ambulance is only for those paients who do not need any medical help like oxygen any other.',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                  style: TextStyle(fontSize: 13),
                                )
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '\$${totalMoney(selectHospital).toStringAsFixed(2)}',
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ]),
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Image.asset(
                            'images/pngwing.png',
                            width: 60,
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Advanced Life Saver',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  'This ambulance is for paients who need oxygen Facility.',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                  style: TextStyle(fontSize: 13),
                                )
                              ],
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '\$${(totalMoney(selectHospital)*1.2).toStringAsFixed(2)}',
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Plate number:', style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                      ),),
                      Text('$plate_number', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ))
                    ],
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: Container(
            margin: EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Confirm and Book", style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              ),),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          isEmergency ? 'Emergency Book' : 'Normal Book',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await _showDialogConfirm();
              // Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => const HomeScreen()));
            },
            child: const Text('Create Booking'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Change to: '),
                  ElevatedButton(
                      onPressed: setEmergencyBooking,
                      child: Text(isEmergency
                          ? 'Normal Booking'
                          : 'Emergency Booking')),
                ],
              ),
              Form(
                key: _formKeyAmbulance,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    isEmergency
                        ? const SizedBox.shrink()
                        : TextFormField(
                            decoration: ambulanceFormField('Patient name'),
                            autocorrect: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please fill type';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _namePatient = value!;
                            },
                          ),
                    isEmergency
                        ? const SizedBox.shrink()
                        : const SizedBox(height: 10),
                    TextFormField(
                      controller: _phoneController, // Link controller here
                      decoration: ambulanceFormField('Phone Number'),
                      autocorrect: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please fill in phone number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _phoneNumber = value!;
                      },
                    ),
                    const SizedBox(height: 16),
                    // TextFormField(
                    //   decoration: ambulanceFormField('Address'),
                    //   autocorrect: true,
                    //   validator: (value) {
                    //     if (value == null || value.trim().isEmpty) {
                    //       return 'Please fill in address';
                    //     }
                    //     return null;
                    //   },
                    //   onSaved: (value) {
                    //     _address = value!;
                    //   },
                    // ),
                    SizedBox(
                      height: 330, // Specify a height
                      child: MapSearchAndPickWidget(
                        onPicked: (pickedData) {
                          // print('===================================');
                          // print(pickedData.latLong.latitude);
                          // print(pickedData.latLong.longitude);
                          // print(pickedData.address);
                          // print(pickedData.addressName);
                          // print('===================================');
                          setState(() {
                            _selectedLocation = LatLng(
                              pickedData.latLong.latitude,
                              pickedData.latLong.longitude,
                            );
                            _address = pickedData.addressName;
                          });
                          print(_selectedLocation);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_showError)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please select a valid location and address before creating.',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    // const SizedBox(height: 16),
                    if (_address != '' && _address != null)
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        minLines: 2,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: _address),
                        enabled: false,
                      ),
                    isEmergency
                        ? const SizedBox.shrink()
                        : const SizedBox(height: 16),
                    isEmergency
                        ? const SizedBox.shrink()
                        : TextFormField(
                            decoration: ambulanceFormField('Zip code'),
                            autocorrect: true,
                            onSaved: (value) {
                              _zipCode = value!;
                            },
                          ),
                    const SizedBox(height: 16),
                    isEmergency
                        ? const SizedBox.shrink()
                        : Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border:
                                            Border.all(color: Colors.black)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedDate == null
                                              ? 'Select date'
                                              : '${selectedDate?.day.toString()}-${selectedDate?.month.toString()}-${selectedDate?.year.toString()}',
                                        ),
                                        const Icon(
                                            Icons.calendar_month_outlined)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 30),
                              const Text('am'),
                              Radio(
                                value: 'am',
                                groupValue: _timeRange,
                                onChanged: (value) {
                                  setState(() {
                                    _timeRange = value!;
                                  });
                                },
                              ),
                              const Text('pm'),
                              Radio(
                                value: 'pm',
                                groupValue: _timeRange,
                                onChanged: (value) {
                                  setState(() {
                                    _timeRange = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                    isEmergency
                        ? const SizedBox.shrink()
                        : const SizedBox(height: 16),
                    // const Text('Select location'),
                    // LocationInput(onSelectLocation: (location) {
                    //   setState(() {
                    //     _selectedLocation = location;
                    //   });
                    // }),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_selectedLocation == null) {
                            showSnackBar(
                                context, 'Please select location first');
                            return;
                          }
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              builder: (BuildContext context) {
                                return Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.9,
                                  child: Scaffold(
                                    appBar: AppBar(
                                      title: const Text('Select Hospital'),
                                      centerTitle: true,
                                    ),
                                    body: Column(
                                      children: [
                                        Flexible(
                                          child: StreamBuilder(
                                            stream: _hospitalsCollection
                                                .snapshots(),
                                            builder: (context,
                                                AsyncSnapshot<QuerySnapshot>
                                                    streamSnapshot) {
                                              var isLoading2 = true;
                                              if (streamSnapshot.hasData) {
                                                final dataList =
                                                    streamSnapshot.data!.docs;
                                                List outputData = [];
                                                for (var i = 0;
                                                    i < dataList.length;
                                                    i++) {
                                                  var object =
                                                      dataList[i].data() as Map;
                                                  object.putIfAbsent(
                                                      'distance',
                                                      () => FlutterMapMath()
                                                          .distanceBetween(
                                                              _selectedLocation!
                                                                  .latitude,
                                                              _selectedLocation!
                                                                  .longitude,
                                                              double.parse(
                                                                  dataList[i][
                                                                      'latitude']),
                                                              double.parse(
                                                                  dataList[i][
                                                                      'longitude']),
                                                              'kilometers'));
                                                  object['distance'] = FlutterMapMath()
                                                      .distanceBetween(
                                                          _selectedLocation!
                                                              .latitude,
                                                          _selectedLocation!
                                                              .longitude,
                                                          double.parse(
                                                              dataList[i]
                                                                  ['latitude']),
                                                          double.parse(dataList[
                                                              i]['longitude']),
                                                          'kilometers');
                                                  outputData.add(object);
                                                }

                                                outputData.sort((a, b) =>
                                                    a['distance'].compareTo(
                                                        b['distance']));
                                                outputData.reversed;

                                                return StatefulBuilder(builder:
                                                    (BuildContext context,
                                                        setState) {
                                                  if (outputData.isNotEmpty) {
                                                    setState(() {
                                                      isLoading2 = false;
                                                    });
                                                  }

                                                  return isLoading2
                                                      ? const CircularProgressIndicator()
                                                      : SingleChildScrollView(
                                                          child:
                                                              ListView.builder(
                                                            physics:
                                                                const ClampingScrollPhysics(),
                                                            shrinkWrap: true,
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            itemCount:
                                                                outputData
                                                                    .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              final data =
                                                                  outputData[
                                                                      index];
                                                              return RadioListTile(
                                                                selectedTileColor:
                                                                    Colors.blue,
                                                                title:
                                                                    HospitalSelectCard(
                                                                  hospital:
                                                                      data,
                                                                  color: selectHospital !=
                                                                              null &&
                                                                          data['id'] ==
                                                                              selectHospital[
                                                                                  'id']
                                                                      ? Colors
                                                                          .blue
                                                                          .shade50
                                                                      : Colors
                                                                          .white,
                                                                  bkgDate:
                                                                      selectedDate,
                                                                  timeRange:
                                                                      _timeRange,
                                                                ),
                                                                value: data,
                                                                groupValue:
                                                                    selectHospital,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    selectHospital =
                                                                        value!;
                                                                  });
                                                                },
                                                              );
                                                            },
                                                          ),
                                                        );
                                                });
                                              }
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.blue,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    bottomNavigationBar: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white),
                                        child: const Text('Select'),
                                      ),
                                    ),
                                  ),
                                );
                              }).whenComplete(onGoBack);
                        },
                        child: Text(selectHospital != null
                            ? selectHospital['name']
                            : 'Select Hospital'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration ambulanceFormField(String text) {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          const Text('*', style: TextStyle(color: Colors.red)),
        ],
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: Colors.white,
      errorStyle: const TextStyle(color: Colors.red),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
