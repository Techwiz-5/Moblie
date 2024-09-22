import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/data/google_auth.dart';
import 'package:techwiz_5/ui/admin/admin_screen.dart';
import 'package:techwiz_5/ui/driver/driver_google_map_pickup.dart';
import 'package:techwiz_5/ui/driver/driver_page.dart';
import 'package:techwiz_5/ui/forgot_password.dart';
import 'package:techwiz_5/ui/sign_up_driver.dart';
import 'package:techwiz_5/ui/sign_up_screen.dart';
import 'package:techwiz_5/ui/user/home_page.dart';
import 'package:techwiz_5/ui/widgets/button.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
import 'package:techwiz_5/ui/widgets/text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKeyLogin = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserStatus(
      String userId, bool isOnline, bool isDriver) async {
    String collection = isDriver ? 'driver' : 'account';
    await FirebaseFirestore.instance.collection(collection).doc(userId).update({
      'online': isOnline,
    });
  }

  void loginUser() async {
    final isValid = _formKeyLogin.currentState!.validate();
    if (!isValid) return;

    _formKeyLogin.currentState!.save();
    try {
      UserCredential userData = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (!userSnapshot.exists) {
          userSnapshot = await FirebaseFirestore.instance
              .collection('driver')
              .doc(user.uid)
              .get();
        }

        bool isDriver = false;
        if (userSnapshot.exists && userSnapshot.data() != null) {
          var userData = userSnapshot.data() as Map<String, dynamic>;
          if (userData.containsKey('role') && userData['role'] == 'driver') {
            isDriver = true;
          }
        }
        await updateUserStatus(user.uid, true, isDriver);
      }

      if (userData.user != null) {
        String uid = userData.user!.uid;
        DocumentSnapshot userDoc =
            await _firestore.collection('account').doc(uid).get();

        if (!userDoc.exists) {
          userDoc = await _firestore.collection('driver').doc(uid).get();

          if (userDoc.exists) {
            await _firestore.collection('driver').doc(uid).update({
              'fcm_token': await FirebaseMessaging.instance.getToken(),
            });
          } else {
            showSnackBar(context, 'User does not exist in both collections');
            return;
          }
        }

        Map<String, dynamic> userRole = userDoc.data() as Map<String, dynamic>;

        switch (userRole['role']) {
          case 'admin':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const AdminScreen(),
              ),
            );
            break;
          case 'driver':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DriverPage(
                  driverId: userRole['uid'],
                ),
              ),
            );
            break;
          case 'user':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
            break;
          default:
            showSnackBar(context, 'Unknown user role');
            return;
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case 'network-request-failed':
          showSnackBar(context, 'No Internet Connection');
          break;
        case 'wrong-password':
          showSnackBar(context, 'Please Enter correct password');
          break;
        case 'user-not-found':
          showSnackBar(context, 'Email not found');
          break;
        case 'too-many-requests':
          showSnackBar(context, 'Too many attempts please try later');
          break;
        default:
          showSnackBar(context, 'Authentication failed');
          return;
      }
    } catch (e) {
      showSnackBar(context, 'An unexpected error occurred: $e');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: height / 3.7,
                child: Image.asset('images/login.jpg'),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FluentIcons.vehicle_bus_20_filled, size: 26, color: Colors.blue[900],),
                    const SizedBox(width: 8),
                    Text('T1 AMBULANCE',style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.blue[900]
                    ),)
                  ],
                ),
              ),
              Form(
                key: _formKeyLogin,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFieldInput(
                      textEditingController: emailController,
                      hintText: 'Enter your email',
                      icon: Icons.email,
                      textInputType: TextInputType.text,
                      errorMessage: (value) {
                        if (value.trim().isEmpty ||
                            !value.contains('@') ||
                            value.startsWith(" ")) {
                          return 'Email is not valid';
                        }
                        return null;
                      },
                    ),
                    TextFieldInput(
                      textEditingController: passwordController,
                      hintText: 'Enter your password',
                      icon: Icons.lock,
                      textInputType: TextInputType.text,
                      isPass: true,
                      errorMessage: (value) {
                        if (value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const ForgotPassword(),
                    MyButtons(onTap: loginUser, text: 'Log In'),
                    Row(
                      children: [
                        Expanded(
                            child: Container(height: 1, color: Colors.black26)),
                        const Text(' or '),
                        Expanded(
                            child: Container(height: 1, color: Colors.black26)),
                      ],
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey),
                        onPressed: () async {
                          await FirebaseServices().signInWithGoogle();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const HomeScreen()),
                          );
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child:
                                  Image.asset('images/logo_google.png', height: 35),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Continue with Google",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?",
                            style: TextStyle(fontSize: 16)),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          ),
                          child: const Text(" SignUp",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Sign up to become a driver ",
                            style: TextStyle(fontSize: 16)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignUpDriverScreen()));
                          },
                          child: const Text("here",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blue)),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
