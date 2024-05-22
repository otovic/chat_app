import 'package:flutter/material.dart';

import '../utility/server.dart';

class AppState with ChangeNotifier {
  Server? server;
  String username = "";
  String balancerIP = "";
  int balancerPort = 0;
}
