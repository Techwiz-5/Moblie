import 'package:flutter/material.dart';
import 'package:techwiz_5/data/authentication.dart';
import 'package:techwiz_5/ui/user/home_page.dart';
import 'package:techwiz_5/ui/login_screen.dart';
import 'package:techwiz_5/ui/widgets/button.dart';
import 'package:techwiz_5/ui/widgets/snackbar.dart';
import 'package:techwiz_5/ui/widgets/text_field.dart';

class SignUpDriverScreen extends StatefulWidget {
  const SignUpDriverScreen({super.key});

  @override
  State<SignUpDriverScreen> createState() => _SignUpDriverScreenState();
}

class _SignUpDriverScreenState extends State<SignUpDriverScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isLoading = false;

  void signUpDriver() async {
    String res = await AuthServices().signUpDriver(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
      phone: phoneController.text,
      address: addressController.text,
    );

    if (res == 'Successfully') {
      setState(() {
        isLoading = true;
      });
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()));
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
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
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
                height: height / 2.8,
                child: Image.asset('images/signup.jpeg'),
              ),
              TextFieldInput(
                textEditingController: nameController,
                hintText: 'Enter your name',
                icon: Icons.person,
                textInputType: TextInputType.text,
              ),
              TextFieldInput(
                textEditingController: phoneController,
                hintText: 'Enter your phone',
                icon: Icons.phone,
                textInputType: TextInputType.text,
              ),
              TextFieldInput(
                textEditingController: addressController,
                hintText: 'Enter your address',
                icon: Icons.home,
                textInputType: TextInputType.text,
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
                isPass: true,
                icon: Icons.lock,
                textInputType: TextInputType.text,
              ),
              MyButtons(onTap: signUpDriver, text: 'Sign Up'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return const LoginScreen();
                        }),
                      );
                    },
                    child: const Text(
                      " Login",
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
