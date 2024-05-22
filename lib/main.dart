import 'dart:convert';
import 'dart:math';

import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/state/state.dart';
import 'package:chat_app/utility/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
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
        home: HomeScreen());
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
  String status = "";

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
        server = Server(ip: parts[1], port: [
          int.parse(parts[2]),
          int.parse(parts[3]),
          int.parse(parts[4])
        ]);

        print('Server: ${server!.ip}:${server!.port}');

        connectToServer();
        break;
      case 'rs//connection_accepted':
        messages.add('Connection accepted');
        break;
      case 'rs//connection_refused':
        messages.add('Connection refused');
        break;
      case 'rs//request_connection_error':
        print('Request connection error: $message');
        break;
      default:
        print('Unknown message: $message');
    }
  }

  void connectToBalancer() async {
    try {
      balancer = await Socket.connect('192.168.0.107', 12344);
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

  void parseServerMessage(String message) {
    switch (status.split(":")[0]) {
      case 'rs//available_people':
        print('Available people: $message');
        break;
      default:
        print('Unknown message: $message');
    }
  }

  void connectToServer() async {
    if (server == null) {
      messages.add('No server available');
      return;
    }

    print('Connecting to server: ${server!.ip}:${server!.port}');

    try {
      Random random = Random();
      int randomPort = 0 + random.nextInt(2 - 0 + 1);
      print('Random port: $randomPort');
      Socket socket =
          await Socket.connect(server!.ip, server!.port![randomPort]);
      print(
          'Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

      server!.socket = socket;

      socket.listen((data) {
        String message = utf8.decoder.convert(data);
        parseServerMessage(message);
      }, onDone: () {
        print('Server disconnected');
        socket.destroy();
      }, onError: (e) {
        print('Error: $e');
      });

      socket.write('cf//username:Petar Otovic\n');
      server!.sendMessage("rq//available_people\n");
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
