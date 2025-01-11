import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_map/uber_Clone/driver_app/auth_screen/signup_screen.dart';
import 'package:google_map/uber_Clone/driver_app/method/common_method.dart';
import 'package:google_map/uber_Clone/driver_app/pages/dashboard.dart';
import 'package:google_map/uber_Clone/driver_app/widgets/loading_dialoge.dart';

class LoginScreenDriverApp extends StatefulWidget {
  const LoginScreenDriverApp({super.key});

  @override
  State<LoginScreenDriverApp> createState() => _LoginScreenDriverAppState();
}

TextEditingController emailController =
    TextEditingController(text: "johndoe@example.com");
TextEditingController passwordController =
    TextEditingController(text: "123456789");

class _LoginScreenDriverAppState extends State<LoginScreenDriverApp> {
  CommonMethodForDriverApp commonMethod = CommonMethodForDriverApp();

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
        return const LoadingDialogeDriverApp(message: "Logging in...");
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
            .child('Drivers')
            .child(userFirebase.uid);
        newUserRef.once().then((snap) {
          final data = snap.snapshot.value as Map?;
          if (data != null) {
            if (data["blockStatus"] == "no") {
              // userName = data["name"];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DashboardPage()));
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('images/driverApp/uberexec.png'),
                const Text(
                  "Create Driver's Account",
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
                            builder: (context) => const SignupScreenDriverApp(),
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
      ),
    );
  }
}
