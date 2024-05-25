import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/utility/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

import '../state/state.dart';

class LobbyScreen extends StatefulWidget {
  LobbyScreen({super.key});
  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late AppState appState;
  bool firstLoad = true;

  @override
  void initState() {
    super.initState();
    appState = Provider.of<AppState>(context, listen: false);
    appState.addListener(_handleStateChange);
  }

  void _handleStateChange() {
    if (appState.server == null) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  void endChat() {
    appState.removeListener(_handleStateChange);
    appState.server!.disconnect();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appState.username),
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: appState.server!.users.length == 0
                  ? const Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          "There is no people available for chat at this time. Chat will refresh when someone is available.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: appState.server!.users.length,
                      itemBuilder: (context, index) {
                        var user =
                            appState.server!.users.values.elementAt(index);
                        return ListTile(
                          title: Text(user.username),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
            ),
            onPressed: () {
              endChat();
            },
            child: Text("Exit Chat"),
          ),
        ),
      ),
    );
  }
}
