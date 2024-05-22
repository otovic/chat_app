import 'dart:io';

class Server {
  late String? ip;
  late List<int>? port;
  late Socket? socket;

  Server({this.ip, this.port, this.socket});

  void sendMessage(String message) {
    socket?.write(message);
  }
}
