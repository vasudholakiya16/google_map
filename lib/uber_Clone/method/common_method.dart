import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class CommonMethod {
  checkConnectivity(BuildContext context) async {
    // check internet connection

    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      if (!context.mounted) {
        return;
      }

      displaySnackBar("Your Internet is not working. Try again", context);
    }
  }

  // check internet connection
  displaySnackBar(String messageContent, BuildContext context) {
    final snackBar = SnackBar(
      content: Text(messageContent),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return snackBar;
  }
}
