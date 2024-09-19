import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techwiz_5/data/authentication.dart';
import 'package:techwiz_5/data/google_auth.dart';
import 'package:techwiz_5/ui/admin/admin_screen.dart';
import 'package:techwiz_5/ui/forgot_password.dart';
import 'package:techwiz_5/ui/user/home_page.dart';
import 'package:techwiz_5/ui/sign_up_screen.dart';
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

  Future<DocumentSnapshot> getUserData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return await _firestore.collection('account').doc(uid).get();
  }

  void loginUser() async {
    final isValid = _formKeyLogin.currentState!.validate();
    if(!isValid) return;
    _formKeyLogin.currentState!.save();
    try{
      UserCredential userData = await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
      );

      if(userData != null){
        String uid = FirebaseAuth.instance.currentUser!.uid;
        final userDoc = await _firestore.collection('account').doc(uid).get();
        Map<String, dynamic> userRole = userDoc.data()!;

        switch(userRole!['role']){
          case 'admin':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => AdminScreen(userData: userData),
              ),
            );
            break;
          case 'driver':
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
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
            return;
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      switch(e.code){
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
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: _formKeyLogin,
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: height / 2.7,
                  child: Image.asset('images/login.jpg'),
                ),
                TextFieldInput(
                  textEditingController: emailController,
                  hintText: 'Enter your email',
                  icon: Icons.email,
                  textInputType: TextInputType.text,
                  errorMessage: (value) {
                    if(value.trim() == '' || !value.contains('@') || value.startsWith(" ")){
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
                    if(value == ''){
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
                      child: Container(
                        height: 1,
                        color: Colors.black26,
                      ),
                    ),
                    const Text(' or '),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.black26,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 10,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey),
                    onPressed: () async {
                      await FirebaseServices().signInWithGoogle();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Image.asset(
                            'images/logo_google.png',
                            height: 35,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          "Continue with Google",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return const SignUpScreen();
                          }),
                        );
                      },
                      child: const Text(
                        " SignUp",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
