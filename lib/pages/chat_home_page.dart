import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/user_tile.dart';
import 'package:social_app/pages/chat_page.dart';
import 'package:social_app/services/chat/chat_service.dart';

class ChatHomePage extends StatelessWidget {
  ChatHomePage({super.key});

  //current user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //chat service
  final ChatService _chatService = ChatService();

  //build a list of users except for the current login user
  Widget _buildUsersList() {
    return StreamBuilder(
      stream: _chatService.getUserStream(),
      builder: (context, snapshot) {
        //error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        //return list view
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUsersListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  //build individual list tile for user
  Widget _buildUsersListItem(
      Map<String, dynamic> userData, BuildContext context) {
    //display all users except current user
    if (userData["email"] != currentUser.email) {
      return UserTile(
        text: userData["username"],
        onTap: () {
          //go to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverID: userData["uid"],
                receiverEmail: userData["username"],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Chat Home",
          ),
        ),
      ),
      body: _buildUsersList(),
    );
  }
}
