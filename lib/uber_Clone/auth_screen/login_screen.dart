import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_map/uber_Clone/auth_screen/signup_screen.dart';
import 'package:google_map/uber_Clone/global/globad_var.dart';
import 'package:google_map/uber_Clone/method/common_method.dart';
import 'package:google_map/uber_Clone/pages/home_page.dart';
import 'package:google_map/uber_Clone/widgets/loading_dialoge.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();

class _LoginScreenState extends State<LoginScreen> {
  CommonMethod commonMethod = CommonMethod();

  Future<void> checkIfNetworkIsAvailable(BuildContext context) async {
    await commonMethod.checkConnectivity(context);
    signinValidation(context);
  }

  void signinValidation(BuildContext context) {
    if (emailController.text.trim().isEmpty) {
      commonMethod.displaySnackBar("Email cannot be empty", context);
    } else if (!emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      commonMethod.displaySnackBar("Invalid email format", context);
    } else if (passwordController.text.trim().isEmpty ||
        passwordController.text.length < 6) {
      commonMethod.displaySnackBar(
          "Password is empty or less than 6 characters", context);
    } else {
      signinUser(context);
    }
  }

  signinUser(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const LoadingDialoge(message: "Logging in...");
      },
    );

    try {
      final User? userFirebase =
          (await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text.trim(),
      ))
              .user;

      if (!context.mounted) return;
      Navigator.pop(context);

      if (userFirebase != null) {
        DatabaseReference newUserRef = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(userFirebase.uid);
        newUserRef.once().then((snap) {
          final data = snap.snapshot.value as Map?;
          if (data != null) {
            if (data["blockStatus"] == "no") {
              userName = data["name"];
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HomePage()));
            } else {
              FirebaseAuth.instance.signOut();
              commonMethod.displaySnackBar(
                  "You are blocked by admin. Please contact admin", context);
            }
          } else {
            FirebaseAuth.instance.signOut();
            commonMethod.displaySnackBar(
                "User not found. Please register first", context);
          }
        });
      }
    } catch (error) {
      Navigator.pop(context);
      commonMethod.displaySnackBar(error.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset('images/logo.png'),
              const Text(
                "Create User's Account",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        labelStyle: const TextStyle(fontSize: 14),
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        labelStyle: const TextStyle(fontSize: 14),
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkIsAvailable(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
