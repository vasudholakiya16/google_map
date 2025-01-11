import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_map/uber_Clone/driver_app/widgets/loading_dialoge.dart';
import 'package:google_map/uber_Clone/user_app/auth_screen/login_screen.dart';
import 'package:google_map/uber_Clone/user_app/method/common_method.dart';
import 'package:google_map/uber_Clone/user_app/pages/home_page.dart';

class SignupScreenUserApp extends StatefulWidget {
  const SignupScreenUserApp({super.key});

  @override
  State<SignupScreenUserApp> createState() => _SignupScreenUserAppState();
}

TextEditingController nameController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController mobileNumberController = TextEditingController();

CommonMethod commonMethod = CommonMethod();

Future<void> checkIfNetworkIsAvailable(BuildContext context) async {
  await commonMethod.checkConnectivity(context);
  signupFormValidation(context);
}

void signupFormValidation(BuildContext context) {
  if (nameController.text.trim().isEmpty || nameController.text.length < 3) {
    commonMethod.displaySnackBar(
        "Name is empty or less than 3 characters", context);
  } else if (mobileNumberController.text.trim().isEmpty ||
      mobileNumberController.text.length < 10) {
    commonMethod.displaySnackBar(
        "Mobile number is empty or less than 10 characters", context);
  } else if (emailController.text.trim().isEmpty ||
      !emailController.text.contains('@') ||
      !emailController.text.contains('.')) {
    commonMethod.displaySnackBar("Email is empty or invalid", context);
  } else if (passwordController.text.trim().isEmpty ||
      passwordController.text.length < 6) {
    commonMethod.displaySnackBar(
        "Password is empty or less than 6 characters", context);
  } else {
    registerNewUser(context);

    // commonMethod.displaySnackBar("Signup Successful", context);
    // Implement signup functionality here
  }
}

registerNewUser(BuildContext context) async {
  // Implement signup functionality here
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return const LoadingDialogeDriverApp(message: "Signing up...");
    },
  );

  // method for authentication
  final User? userFirebase = (await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
    email: emailController.text,
    password: passwordController.text.trim(),
  )
          // ignore: body_might_complete_normally_catch_error
          .catchError((error) {
    Navigator.pop(context);
    commonMethod.displaySnackBar(error.toString(), context);
  }))
      .user;

  if (!context.mounted) return;
  Navigator.pop(context);

  // store user data in firestore
  DatabaseReference newUserRef =
      FirebaseDatabase.instance.ref().child('users').child(userFirebase!.uid);

  Map userDataMap = {
    'name': nameController.text.trim(),
    'email': emailController.text.trim(),
    'number': mobileNumberController.text.trim(),
    'id': userFirebase.uid,
    'password': passwordController.text.trim().hashCode,
    'blockStatus': 'no',
  };

  newUserRef.set(userDataMap);
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => const HomePage()));
}

class _SignupScreenUserAppState extends State<SignupScreenUserApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset('images/userApp/logo.png'),
              const Text(
                "Create User's Account",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Name',
                        hintText: 'Enter your name',
                        labelStyle: const TextStyle(fontSize: 14),
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: mobileNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: 'Mobile Number',
                        hintText: 'Enter your mobile number',
                        labelStyle: const TextStyle(fontSize: 14),
                        hintStyle:
                            const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ),
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
                        'Sign Up',
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
                    "Already have an account? ",
                    style: TextStyle(fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreenUserApp(),
                        ),
                      );
                    },
                    child: const Text(
                      "Login",
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
