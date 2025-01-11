import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_map/uber_Clone/driver_app/auth_screen/login_screen.dart';
import 'package:google_map/uber_Clone/driver_app/method/common_method.dart';
import 'package:google_map/uber_Clone/driver_app/pages/dashboard.dart';
import 'package:google_map/uber_Clone/driver_app/widgets/loading_dialoge.dart';
import 'package:image_picker/image_picker.dart';

class SignupScreenDriverApp extends StatefulWidget {
  const SignupScreenDriverApp({super.key});

  @override
  State<SignupScreenDriverApp> createState() => _SignupScreenDriverAppState();
}

class _SignupScreenDriverAppState extends State<SignupScreenDriverApp> {
  // Image for profile
  XFile? imageFile;
  String urlOfUploadImage = '';

  // Text controllers for the form fields
  final nameController = TextEditingController(text: "John Doe");
  final emailController =
      TextEditingController(text: "johndoe14778900147147@example.com");
  final passwordController = TextEditingController(text: "123456789");
  final mobileNumberController = TextEditingController(text: "9876543210");
  final carModelController = TextEditingController(text: "Toyota Prius");
  final carNumberController = TextEditingController(text: "GJ01AA1234");
  final carColorController = TextEditingController(text: "Black");

  CommonMethodForDriverApp commonMethod = CommonMethodForDriverApp();

  Future<void> checkIfNetworkIsAvailable(BuildContext context) async {
    await commonMethod.checkConnectivity(context);
    if (imageFile != null) {
      chooseImageForGallery(context);
    } else {
      commonMethod.displaySnackBar("Please select a profile image", context);
    }
    signupFormValidation(context);
  }

  void signupFormValidation(BuildContext context) {
    final carNumberRegex = RegExp(r'^[A-Z]{2}\d{2}[A-Z]{1,2}\d{4}$');
    final allowedColors = ['red', 'blue', 'black', 'white', 'green', 'yellow'];

    if (nameController.text.trim().isEmpty || nameController.text.length < 3) {
      commonMethod.displaySnackBar(
          "Name is empty or less than 3 characters", context);
    } else if (mobileNumberController.text.trim().isEmpty ||
        mobileNumberController.text.length != 10 ||
        !RegExp(r'^\d+$').hasMatch(mobileNumberController.text.trim())) {
      commonMethod.displaySnackBar("Invalid Mobile Number", context);
    } else if (emailController.text.trim().isEmpty ||
        !emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      commonMethod.displaySnackBar("Email is empty or invalid", context);
    } else if (passwordController.text.trim().isEmpty ||
        passwordController.text.length < 6) {
      commonMethod.displaySnackBar(
          "Password is empty or less than 6 characters", context);
    } else if (carModelController.text.trim().isEmpty) {
      commonMethod.displaySnackBar("Car Model is empty", context);
    } else if (carNumberController.text.trim().isEmpty ||
        !carNumberRegex.hasMatch(carNumberController.text.trim())) {
      commonMethod.displaySnackBar(
          "Car Number is empty or invalid (e.g., GJ01AA1234)", context);
    } else if (carColorController.text.trim().isEmpty ||
        !allowedColors.contains(carColorController.text.trim().toLowerCase())) {
      commonMethod.displaySnackBar(
          "Car Color is empty or not valid (allowed: ${allowedColors.join(', ')})",
          context);
    } else {
      // Call the registerNewUser function if all validations pass
      registerNewUsers(context);
    }
  }

  // Register new user function
  registerNewUsers(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const LoadingDialogeDriverApp(message: "Signing up...");
      },
    );

    try {
      // Firebase authentication process
      final User? userFirebase = (await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text.trim(),
      )
              .catchError((error) {
        throw error; // Handle specific errors
      }))
          .user;

      if (userFirebase == null) {
        throw Exception("User creation failed"); // Handle user creation failure
      }

      // Proceed with database storage
      DatabaseReference newUserRef = FirebaseDatabase.instance
          .ref()
          .child('Drivers')
          .child(userFirebase.uid);

      Map userDataMap = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'number': mobileNumberController.text.trim(),
        'id': userFirebase.uid,
        'password': passwordController.text.trim(),
        'blockStatus': 'no',
        'carModel': carModelController.text.trim(),
        'carNumber': carNumberController.text.trim(),
        'carColor': carColorController.text.trim(),
        'dateCreated': DateTime.now().toString(),
        'dateUpdated': DateTime.now().toString(),
        'driverActiveStatus': 'yes',
        'profileImage': imageFile?.path ?? '',
      };
      print(userDataMap);

      await newUserRef.set(userDataMap);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DashboardPage()),
      );
    } catch (error) {
      Navigator.pop(context);
      if (error is FirebaseAuthException) {
        commonMethod.displaySnackBar(
            "Authentication error: ${error.message}", context);
      } else {
        commonMethod.displaySnackBar("Error: $error", context);
      }
    }
  }

  // Image selection function
  chooseImageForGallery(BuildContext context) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = XFile(pickedFile.path);
      });

      // Upload image to Firebase Storage
      try {
        String imageIdName = DateTime.now().millisecondsSinceEpoch.toString();
        final storageRef =
            FirebaseStorage.instance.ref().child("images").child(imageIdName);
        UploadTask uploadTask = storageRef.putFile(File(pickedFile.path));
        TaskSnapshot taskSnapshot = await uploadTask;
        urlOfUploadImage = await taskSnapshot.ref.getDownloadURL();
        setState(() {
          imageFile = XFile(urlOfUploadImage);
        });
      } catch (error) {
        commonMethod.displaySnackBar("Failed to upload image: $error", context);
      }
    } else {
      commonMethod.displaySnackBar("No image selected", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                imageFile != null
                    ? CircleAvatar(
                        radius: 86,
                        backgroundImage: FileImage(File(imageFile!.path)),
                      )
                    : CircleAvatar(
                        radius: 86,
                        backgroundImage:
                            const AssetImage('images/driverApp/avatarman.png'),
                      ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    chooseImageForGallery(context);
                  },
                  child: Text(
                    "Select Your Profile",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
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
                      TextFormField(
                        controller: carModelController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Car Model',
                          hintText: 'Enter your car model',
                          labelStyle: const TextStyle(fontSize: 14),
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: carNumberController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Car Number',
                          hintText: 'Enter your car number',
                          labelStyle: const TextStyle(fontSize: 14),
                          hintStyle:
                              const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: carColorController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Car Color',
                          hintText: 'Enter your car color',
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
                            builder: (context) => const LoginScreenDriverApp(),
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
      ),
    );
  }
}
