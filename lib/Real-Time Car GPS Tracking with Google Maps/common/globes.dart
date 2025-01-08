// import 'package:google_map/main.dart';

// class Globes {
//   static const appName = 'Car GPS Tracking';
//   static void udStringSet(String data, String key) {
//     prefs!.setString(key, data);
//   }

//   static String udValueString(String key) {
//     return prefs!.getString(key) ?? '';
//   }
// }

// class SVKey {
//   static const mainUrl = 'https://127.0.0.1:8000';
//   static const baseUrl = '$mainUrl/api/';
//   static const nodeUrl = mainUrl;
// }

// class KKey {
//   static const payload = "payload";
//   static const status = "status";
//   static const message = "message";
// }

// class MSG {
//   static const success = "Success";
//   static const failed = "Failed";
// }

import 'package:google_map/main.dart';

class Globes {
  static const appName = 'Car GPS Tracking';

  static void udStringSet(String data, String key) {
    prefs!.setString(key, data);
  }

  static String udValueString(String key) {
    return prefs!.getString(key) ?? '';
  }
}

class SVKey {
  // Use the correct URL for local development based on the platform
  static const mainUrl = 'http://10.0.2.2:8000'; // For Android Emulator
  // For physical devices, use your machine's IP address (e.g., 192.168.x.x)
  // static const mainUrl = 'http://192.168.x.x:8000'; // Replace with your local machine IP

  static const baseUrl = '$mainUrl/api/';
  static const nodeUrl = mainUrl;
}

class KKey {
  static const payload = "payload";
  static const status = "status";
  static const message = "message";
}

class MSG {
  static const success = "Success";
  static const failed = "Failed";
}
