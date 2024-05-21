import 'dart:io';

class Server {
  late String? ip;
  late int? port;
  late Socket? socket;

  Server({this.ip, this.port, this.socket});
}
