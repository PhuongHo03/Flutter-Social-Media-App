import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/chat_bubble.dart';
import 'package:social_app/components/text_field.dart';
import 'package:social_app/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverID;
  final String receiverEmail;
  ChatPage({
    super.key,
    required this.receiverID,
    required this.receiverEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //text controller
  final textController = TextEditingController();

  //chat services
  final ChatService _chatService = ChatService();

  //current user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text field focus
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //add listener to focus node
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        //cause a delay so that the keyboard has time to show up
        //then the amount of remaining space will be calculated, then scroll down
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });

    //wait a bit for listview to be built, then scroll to bottom
    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    textController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //send message
  void sendMessage() async {
    //if there is something inside the text field
    if (textController.text.isNotEmpty) {
      //send the message
      await _chatService.sendMessage(widget.receiverID, textController.text);

      //clear the text controller
      textController.clear();
    }

    //scroll down after send a message
    scrollDown();
  }

  //build messages list
  Widget _buildMessagesList() {
    String senderID = currentUser.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(senderID, widget.receiverID),
      builder: (context, snapshot) {
        //errors
        if (snapshot.hasError) {
          return const Text("Error");
        }

        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        //return list view
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is current user
    bool isCurrentUser = data["senderID"] == currentUser.uid;

    //align message to the right if sender is the current user, otherwise left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: ChatBubble(
        message: data["message"],
        isCurrentUser: isCurrentUser,
      ),
    );
  }

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
            widget.receiverEmail,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          //display all messages
          Expanded(child: _buildMessagesList()),

          //user input
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                //text field
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: "Write something..",
                    obscureText: false,
                    focusNode: myFocusNode,
                  ),
                ),

                //post button
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(
                    Icons.arrow_circle_up,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
