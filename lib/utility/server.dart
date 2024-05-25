import 'dart:convert';
import 'dart:io';

import 'package:chat_app/utility/user.dart';

class Server {
  late String? username;
  late Map<String, User> users = {};
  late String? ip;
  late List<int>? ports;
  late Socket? socket;
  late Function onConnectionSuccess;
  late Function onConnectionError;

  Server({
    this.username,
    this.ip,
    this.ports,
    this.socket,
    required this.onConnectionSuccess,
    required this.onConnectionError,
  }) {
    connect(ip!, ports![0], onConnectionSuccess);
  }

  void sendMessage(String message) {
    socket?.write(message + "\n");
  }

  void _parseMessage(String message) {
    if (message == "ch//check") {
      socket?.write("rs//check:ok\n");
      return;
    }
    if (message.startsWith("rs//available_people")) {
      if (message.split(":")[1] == "none") {
        return;
      }
      List<String> people = message.split(":");
      for (int i = 1; i < people.length; i++) {
        users[people[i]] = User(username: people[i]);
      }
      return;
    }
  }

  void connect(String ip, int port, Function onSuccess) async {
    try {
      socket = await Socket.connect(ip, port);
      print(
          'Connected to: ${socket!.remoteAddress.address}:${socket!.remotePort}');

      socket!.listen((data) {
        String message = utf8.decoder.convert(data);
        print('Received from server: $message');
        _parseMessage(message);
      }, onDone: () {
        print('Server closed');
        socket!.destroy();
      });

      socket!.write('cf//username:${username}\n');
      socket!.write('rq//available_people\n');
      onConnectionSuccess(this);
    } catch (e) {
      print('Unable to connect to balancer: $e');
    }
  }

  void disconnect() {
    try {
      sendMessage("end");
      socket?.destroy();
      this.socket = null;
    } catch (e) {
      print('Error: $e');
    }
  }
}
