import 'dart:convert';

import 'package:chat_app/utility/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Available people'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Socket balancer;
  final List<String> messages = [];
  final TextEditingController controller = TextEditingController();
  Server? server;

  @override
  void initState() {
    super.initState();
    connectToBalancer();
  }

  @override
  void dispose() {
    print("dispose()");
    balancer.destroy();
    super.dispose();
  }

  void parseMessage(String message) {
    String msgID = message.split(':')[0];
    print('Message ID: $msgID');
    switch (msgID) {
      case 'rs//request_connection_success':
        List<String> parts = message.split(':');
        server = Server(ip: parts[1], port: int.parse(parts[2]));
        connectToServer();
        break;
      case 'rs//connection_accepted':
        messages.add('Connection accepted');
        break;
      case 'rs//connection_refused':
        messages.add('Connection refused');
        break;
      default:
        print('Request connection success');
        messages.add('Unknown message: $message');
    }
  }

  void connectToBalancer() async {
    try {
      balancer = await Socket.connect('192.168.0.107', 12345);
      print(
          'Connected to: ${balancer.remoteAddress.address}:${balancer.remotePort}');

      balancer.listen((data) {
        String message = utf8.decoder.convert(data);
        print('Received: $message');
        parseMessage(message);
      }, onDone: () {
        print('Balancer closed');
        balancer.destroy();
      });

      balancer.write('rq//request_connection\n');
    } catch (e) {
      print('Unable to connect to balancer: $e');
    }
  }

  void connectToServer() async {
    if (server == null) {
      messages.add('No server available');
      return;
    }

    print('Connecting to server: ${server!.ip}:${server!.port}');

    try {
      Socket socket = await Socket.connect(server!.ip, server!.port!);
      print(
          'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

      server!.socket = socket;

      server!.sendMessage("rq//availabe_people\n");

      socket.listen((data) {
        String message = utf8.decoder.convert(data);
        print('Received: $message');
      }, onDone: () {
        print('Server disconnected');
        socket.destroy();
      });

      socket.write('cf//username:Petar Otovic\n');
    } catch (e) {
      print('Unable to connect: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(messages[index]),
                );
              },
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Send a message'),
              onSubmitted: (AboutDialog) {
                if (controller.text.isNotEmpty) {
                  print('Sending message: ${controller.text}');
                  server!.socket!.write(controller.text + '\n');
                  controller.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
