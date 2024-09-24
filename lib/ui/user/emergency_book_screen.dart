import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:techwiz_5/data/notification.dart';
import 'package:techwiz_5/ui/user/booking_history.dart';
import 'package:techwiz_5/ui/user/home_page.dart';
import 'package:techwiz_5/ui/widgets/location_input.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';

import '../widgets/MapSearchAndPick.dart';
import 'hospital_select_card.dart';

class EmergencyBookScreen extends StatefulWidget {
  const EmergencyBookScreen({super.key});

  @override
  State<EmergencyBookScreen> createState() => _EmergencyBookScreenState();
}

class _EmergencyBookScreenState extends State<EmergencyBookScreen> {
  DateFormat dateFormat = DateFormat("dd-MM-yyyy");
  double latitude = 0.0;
  double longitude = 0.0;
  bool isLoading = true;
  bool _showError = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  final CollectionReference _hospitalsCollection =
      FirebaseFirestore.instance.collection('hospital');
  final CollectionReference myItems =
      FirebaseFirestore.instance.collection('booking');
  final CollectionReference _ambulanceCollection =
      FirebaseFirestore.instance.collection('ambulance');
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
  List bookedAmbulance = [];
  List lstAmbulance = [];
  String plate_number = '';

  @override
  void initState() {
    super.initState();
    initRun();
  }

  initRun() async {
    setupPushNotification();
    getUserInfo();
    // getHospitals();
  }

  getUserInfo() async {
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
          _namePatient = userData['name'];
          _nameController.text = _namePatient;
        });
      } else {
        showSnackBar(context, 'User does not exist in both collections');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  getAllAmbulance() async {
    QuerySnapshot querySnapshot = await _ambulanceCollection
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

  String getAmbulancePlate() {
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
    print(rs);
    return rs;

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
        'zip_code': '',
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

  Future<dynamic> getHospitals() async {
    QuerySnapshot querySnapshot = await _hospitalsCollection.get();
    final dataList = querySnapshot.docs.map((doc) => doc.data()).toList();
    List outputData = [];
    for (var i = 0; i < dataList.length; i++) {
      var object = dataList[i] as Map;
      if(object['availableSlot'] == 0) continue;
      object.putIfAbsent(
          'distance',
          () => FlutterMapMath().distanceBetween(
              _selectedLocation!.latitude,
              _selectedLocation!.longitude,
              double.parse(object['latitude']),
              double.parse(object['longitude']),
              'kilometers'));
      object['distance'] = FlutterMapMath().distanceBetween(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
          double.parse(object['latitude']),
          double.parse(object['longitude']),
          'kilometers');
      outputData.add(object);
    }

    outputData.sort((a, b) => a['distance'].compareTo(b['distance']));
    outputData.reversed;
    return outputData.first;
  }

  void createEmergencyBooking(PickedData pickedData) async {

    setState(() {
      _selectedLocation = LatLng(
        pickedData.latLong.latitude,
        pickedData.latLong.longitude,
      );
      _address = pickedData.addressName;
    });
    selectHospital = await getHospitals();
    await getAllAmbulance();
    await getBookedSlot();
    String pltNum = getAmbulancePlate();

    double mn = 0;
      if (selectHospital != null) {
        mn = (selectHospital['distance'] * selectHospital['price']);
        mn = mn + mn * 1.2;
      }
    setState(() {
      plate_number = pltNum;
      money = mn;
    });
    await _createBooking();
    _showDialogSuccess();
  }

  Future<void> _showDialogSuccess() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Successfully',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'images/pngwing.png',
                  width: 60,
                ),
                const Text("Your has booked ambulance successfully \nOur driver will contact you soon.\nThankyou.", textAlign: TextAlign.center,),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(EneftyIcons.hospital_bold, color: Colors.green,),
                    const SizedBox(width: 6,),
                    Flexible(child: Text("${selectHospital['name']}", style: const TextStyle(fontSize: 18, color: Colors.green),)),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.directions_bus_filled, color: Colors.green,),
                    const SizedBox(width: 6,),
                    Text(plate_number, style: const TextStyle(fontSize: 18, color: Colors.green),),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.green,),
                    const SizedBox(width: 6,),
                    Text("\$${money.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),)
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ),
                              (route) => false);
                    },
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingHistoryScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Booking history',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                )
              ],
            ),

          ],
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
        title: const Text(
          'Emergency Book',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                'You are making an Emergency Booking',
                style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
              child: Text(
                'Emergency booking allows you to book a ambulance from your current location to the nearest hospital with a single click.',
                style: TextStyle(
                    color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKeyAmbulance,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: _nameController,
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
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: TextFormField(
                          controller: _phoneController, // Link controller here
                          decoration: ambulanceFormField('Phone Number'),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.black)),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate == null
                                      ? 'Select date'
                                      : '${selectedDate?.day.toString()}-${selectedDate?.month.toString()}-${selectedDate?.year.toString()}',
                                ),
                                const Icon(Icons.calendar_month_outlined)
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
                  const SizedBox(height: 10),
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
                ],
              ),
            ),
            Expanded(
              child: Container(
                // height: 320, // Specify a height
                child: MapSearchAndPickWidget(
                  buttonText: 'One Click To Book',
                  buttonHeight: 45,
                  onPicked: (pickedData) {
                    createEmergencyBooking(pickedData);
                  },
                ),
              ),
            ),
          ],
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
