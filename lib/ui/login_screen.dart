import 'package:flutter/material.dart';
import 'package:techwiz_5/data/authentication.dart';
import 'package:techwiz_5/data/google_auth.dart';
import 'package:techwiz_5/ui/forgot_password.dart';
import 'package:techwiz_5/ui/home_page.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void loginUser() async {
    String res = await AuthServices().loginUser(
        email: emailController.text, password: passwordController.text);

    if (res == 'Successfully') {
      setState(() {
        isLoading = true;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
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
      body: SingleChildScrollView(
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
              ),
              TextFieldInput(
                textEditingController: passwordController,
                hintText: 'Enter your password',
                icon: Icons.lock,
                textInputType: TextInputType.text,
                isPass: true,
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
    );
  }
}
