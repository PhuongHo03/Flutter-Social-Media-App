import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/chat_bubble.dart';
import 'package:social_app/components/text_field.dart';
import 'package:social_app/services/auth/auth_service.dart';
import 'package:social_app/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverID;
  final String receiverEmail;
  const ChatPage({
    super.key,
    required this.receiverID,
    required this.receiverEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //text controller
  final _textController = TextEditingController();

  //get chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  //text field focus
  final FocusNode _myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //add listener to focus node
    _myFocusNode.addListener(() {
      if (_myFocusNode.hasFocus) {
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
    _myFocusNode.dispose();
    _textController.dispose();
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
    if (_textController.text.isNotEmpty) {
      //send the message
      await _chatService.sendMessage(widget.receiverID, _textController.text);

      //clear the text controller
      _textController.clear();
    }

    //scroll down after send a message
    scrollDown();
  }

  //build messages list
  Widget _buildMessagesList() {
    String senderID = _authService.getCurrentUser()!.uid;
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
    bool isCurrentUser = data["senderID"] == _authService.getCurrentUser()!.uid;

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Center(
          child: Text(
            widget.receiverEmail,
          ),
        ),
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
                    controller: _textController,
                    hintText: "Write something..",
                    obscureText: false,
                    focusNode: _myFocusNode,
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
