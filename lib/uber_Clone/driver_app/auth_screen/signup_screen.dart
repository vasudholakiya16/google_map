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

TextEditingController nameController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController mobileNumberController = TextEditingController();
TextEditingController carModelController = TextEditingController();
TextEditingController carNumberController = TextEditingController();
TextEditingController carColorController = TextEditingController();

CommonMethodForDriverApp commonMethod = CommonMethodForDriverApp();

Future<void> checkIfNetworkIsAvailable(BuildContext context) async {
  await commonMethod.checkConnectivity(context);
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
    registerNewUser(context);
  }
}

// image for profile
XFile? imageFile;

chooseImageForGallery(BuildContext context) async {
  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    imageFile = XFile(pickedFile.path);
    // Upload image to Firebase Storage
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('driver_profiles/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = await storageRef.putFile(File(pickedFile.path));
      final imageUrl = await storageRef.getDownloadURL();

      // Add the image URL to the user data during signup
      if (imageUrl.isNotEmpty) {
        commonMethod.displaySnackBar("Image uploaded successfully!", context);
        imageFile = XFile(imageUrl);
      }
    } catch (error) {
      commonMethod.displaySnackBar("Failed to upload image: $error", context);
    }
  } else {
    commonMethod.displaySnackBar("No image selected", context);
  }
}

registerNewUser(BuildContext context) async {
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
      'password': passwordController.text.trim().hashCode,
      'blockStatus': 'no',
      'carModel': carModelController.text.trim(),
      'carNumber': carNumberController.text.trim(),
      'carColor': carColorController.text.trim(),
      'dateCreated': DateTime.now().toString(),
      'dateUpdated': DateTime.now().toString(),
      'driverActiveStatus': 'yes',
    };

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
    } else if (error is SocketException) {
      commonMethod.displaySnackBar(
          "Network error: Please check your connection.", context);
    } else {
      commonMethod.displaySnackBar("Error: $error", context);
    }
  }
}

class _SignupScreenDriverAppState extends State<SignupScreenDriverApp> {
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
                CircleAvatar(
                  radius: 86,
                  backgroundImage:
                      const AssetImage('images/driverApp/avatarman.png'),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    // chooseImageForGallery(context);
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


// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:google_map/uber_Clone/driver_app/auth_screen/login_screen.dart';
// import 'package:google_map/uber_Clone/driver_app/method/common_method.dart';
// import 'package:google_map/uber_Clone/driver_app/pages/dashboard.dart';
// import 'package:google_map/uber_Clone/driver_app/widgets/loading_dialoge.dart';
// import 'package:image_picker/image_picker.dart';

// class SignupScreenDriverApp extends StatefulWidget {
//   const SignupScreenDriverApp({super.key});

//   @override
//   State<SignupScreenDriverApp> createState() => _SignupScreenDriverAppState();
// }

// class _SignupScreenDriverAppState extends State<SignupScreenDriverApp> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController mobileNumberController = TextEditingController();
//   final TextEditingController carModelController = TextEditingController();
//   final TextEditingController carNumberController = TextEditingController();
//   final TextEditingController carColorController = TextEditingController();

//   final CommonMethodForDriverApp commonMethod = CommonMethodForDriverApp();

//   XFile? imageFile;

//   Future<void> chooseImageForGallery(BuildContext context) async {
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         imageFile = XFile(pickedFile.path);
//       });

//       // Upload image to Firebase Storage
//       try {
//         final storageRef = FirebaseStorage.instance
//             .ref()
//             .child('driver_profiles/${DateTime.now().millisecondsSinceEpoch}');
//         await storageRef.putFile(File(pickedFile.path));
//         final imageUrl = await storageRef.getDownloadURL();

//         // Handle successful upload
//         if (imageUrl.isNotEmpty) {
//           commonMethod.displaySnackBar("Image uploaded successfully!", context);
//         }
//       } catch (error) {
//         commonMethod.displaySnackBar("Failed to upload image: $error", context);
//       }
//     } else {
//       commonMethod.displaySnackBar("No image selected", context);
//     }
//   }

//   Future<void> checkIfNetworkIsAvailable(BuildContext context) async {
//     await commonMethod.checkConnectivity(context);
//     signupFormValidation(context);
//   }

//   void signupFormValidation(BuildContext context) {
//     final carNumberRegex = RegExp(r'^[A-Z]{2}\d{2}[A-Z]{1,2}\d{4}$');
//     final allowedColors = ['red', 'blue', 'black', 'white', 'green', 'yellow'];

//     if (nameController.text.trim().isEmpty || nameController.text.length < 3) {
//       commonMethod.displaySnackBar(
//           "Name is empty or less than 3 characters", context);
//     } else if (mobileNumberController.text.trim().isEmpty ||
//         mobileNumberController.text.length != 10 ||
//         !RegExp(r'^\d+$').hasMatch(mobileNumberController.text.trim())) {
//       commonMethod.displaySnackBar("Invalid Mobile Number", context);
//     } else if (emailController.text.trim().isEmpty ||
//         !emailController.text.contains('@') ||
//         !emailController.text.contains('.')) {
//       commonMethod.displaySnackBar("Email is empty or invalid", context);
//     } else if (passwordController.text.trim().isEmpty ||
//         passwordController.text.length < 6) {
//       commonMethod.displaySnackBar(
//           "Password is empty or less than 6 characters", context);
//     } else if (carModelController.text.trim().isEmpty) {
//       commonMethod.displaySnackBar("Car Model is empty", context);
//     } else if (carNumberController.text.trim().isEmpty ||
//         !carNumberRegex.hasMatch(carNumberController.text.trim())) {
//       commonMethod.displaySnackBar(
//           "Car Number is empty or invalid (e.g., GJ01AA1234)", context);
//     } else if (carColorController.text.trim().isEmpty ||
//         !allowedColors.contains(carColorController.text.trim().toLowerCase())) {
//       commonMethod.displaySnackBar(
//           "Car Color is empty or not valid (allowed: ${allowedColors.join(', ')})",
//           context);
//     } else {
//       registerNewUser(context);
//     }
//   }

//   Future<void> registerNewUser(BuildContext context) async {
//   // Show loading dialog
//   showDialog(
//     barrierDismissible: false,
//     context: context,
//     builder: (BuildContext context) {
//       return const LoadingDialogeDriverApp(message: "Signing up...");
//     },
//   );

//   try {
//     // Firebase Authentication
//     final User? userFirebase = (await FirebaseAuth.instance
//         .createUserWithEmailAndPassword(
//       email: emailController.text,
//       password: passwordController.text.trim(),
//     )
//         .catchError((error) {
//       // Handle error here without returning any value
//       Navigator.pop(context);
//       commonMethod.displaySnackBar(error.toString(), context);
//       return null;  // Return null to not affect the Future's result
//     }))
//         ?.user;

//     if (userFirebase != null) {
//       // Store user data in Firebase Realtime Database
//       DatabaseReference newUserRef = FirebaseDatabase.instance
//           .ref()
//           .child('Drivers')
//           .child(userFirebase.uid);

//       Map userDataMap = {
//         'name': nameController.text.trim(),
//         'email': emailController.text.trim(),
//         'number': mobileNumberController.text.trim(),
//         'id': userFirebase.uid,
//         'password': passwordController.text.trim().hashCode,
//         'blockStatus': 'no',
//         'carModel': carModelController.text.trim(),
//         'carNumber': carNumberController.text.trim(),
//         'carColor': carColorController.text.trim(),
//         'dateCreated': DateTime.now().toString(),
//         'dateUpdated': DateTime.now().toString(),
//         'driverActiveStatus': 'yes',
//         // 'profileImage': imageFile?.path ?? '',
//       };

//       await newUserRef.set(userDataMap);

//       Navigator.push(context,
//           MaterialPageRoute(builder: (context) => const DashboardPage()));
//     }
//   } catch (e) {
//     Navigator.pop(context);
//     commonMethod.displaySnackBar("Error: $e", context);
//   }
// }


//   // Future<void> registerNewUser(BuildContext context) async {
//   //   // Show loading dialog
//   //   showDialog(
//   //     barrierDismissible: false,
//   //     context: context,
//   //     builder: (BuildContext context) {
//   //       return const LoadingDialogeDriverApp(message: "Signing up...");
//   //     },
//   //   );

//   //   // Firebase Authentication
//   //   final User? userFirebase = (await FirebaseAuth.instance
//   //           .createUserWithEmailAndPassword(
//   //     email: emailController.text,
//   //     password: passwordController.text.trim(),
//   //   )
//   //           .catchError((error) {
//   //     Navigator.pop(context);
//   //     commonMethod.displaySnackBar(error.toString(), context);
//   //   }))
//   //       ?.user;

//   //   if (!context.mounted) return;
//   //   Navigator.pop(context);

//   //   // Store user data in Firebase Realtime Database
//   //   if (userFirebase != null) {
//   //     DatabaseReference newUserRef = FirebaseDatabase.instance
//   //         .ref()
//   //         .child('Drivers')
//   //         .child(userFirebase.uid);

//   //     Map userDataMap = {
//   //       'name': nameController.text.trim(),
//   //       'email': emailController.text.trim(),
//   //       'number': mobileNumberController.text.trim(),
//   //       'id': userFirebase.uid,
//   //       'password': passwordController.text.trim().hashCode,
//   //       'blockStatus': 'no',
//   //       'carModel': carModelController.text.trim(),
//   //       'carNumber': carNumberController.text.trim(),
//   //       'carColor': carColorController.text.trim(),
//   //       'dateCreated': DateTime.now().toString(),
//   //       'dateUpdated': DateTime.now().toString(),
//   //       'driverActiveStatus': 'yes',
//   //       // 'profileImage': imageFile?.path ?? '',
//   //     };

//   //     newUserRef.set(userDataMap);

//   //     Navigator.push(context,
//   //         MaterialPageRoute(builder: (context) => const DashboardPage()));
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 CircleAvatar(
//                   radius: 86,
//                   backgroundImage:
//                       const AssetImage('images/driverApp/avatarman.png'),
//                 ),
//                 const SizedBox(height: 10),
//                 GestureDetector(
//                   onTap: () {
//                     // chooseImageForGallery(context);
//                   },
//                   child: const Text(
//                     "Select Your Profile",
//                     style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(22),
//                   child: Column(
//                     children: [
//                       buildTextField(nameController, 'Name', 'Enter your name'),
//                       const SizedBox(height: 22),
//                       buildTextField(mobileNumberController, 'Mobile Number',
//                           'Enter your mobile number',
//                           keyboardType: TextInputType.phone),
//                       const SizedBox(height: 22),
//                       buildTextField(
//                           emailController, 'Email', 'Enter your email',
//                           keyboardType: TextInputType.emailAddress),
//                       const SizedBox(height: 22),
//                       buildTextField(
//                           passwordController, 'Password', 'Enter your password',
//                           obscureText: true),
//                       const SizedBox(height: 22),
//                       buildTextField(carModelController, 'Car Model',
//                           'Enter your car model'),
//                       const SizedBox(height: 22),
//                       buildTextField(carNumberController, 'Car Number',
//                           'Enter your car number'),
//                       const SizedBox(height: 22),
//                       buildTextField(carColorController, 'Car Color',
//                           'Enter your car color'),
//                       const SizedBox(height: 22),
//                       ElevatedButton(
//                         onPressed: () {
//                           checkIfNetworkIsAvailable(context);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 50, vertical: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                         ),
//                         child: const Text(
//                           'Sign Up',
//                           style: TextStyle(fontSize: 20, color: Colors.black),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Already have an account? ",
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const LoginScreenDriverApp(),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         "Login",
//                         style: TextStyle(
//                           fontSize: 16,
//                           decoration: TextDecoration.underline,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTextField(
//       TextEditingController controller, String labelText, String hintText,
//       {bool obscureText = false,
//       TextInputType keyboardType = TextInputType.text}) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//         ),
//         labelText: labelText,
//         hintText: hintText,
//         labelStyle: const TextStyle(fontSize: 14),
//         hintStyle: const TextStyle(color: Colors.grey, fontSize: 10),
//       ),
//     );
//   }
// }
