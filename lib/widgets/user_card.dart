import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class UserCard extends StatefulWidget {
  UserCard({super.key, required this.username});
  final String username;

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print("User card tapped");
        },
        splashColor: Colors.grey.withOpacity(0.5),
        highlightColor: Colors.grey.withOpacity(0.5),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 10,
                  child: Text(widget.username,
                      style: const TextStyle(fontSize: 18)),
                ),
                Expanded(
                  flex: 1,
                  child: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
