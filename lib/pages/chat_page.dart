import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  const ChatPage({
    super.key,
    required this.receiverEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        //color of all icon in appbar
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Center(
          child: Text(
            receiverEmail,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.grey[900],
      ),
    );
  }
}
