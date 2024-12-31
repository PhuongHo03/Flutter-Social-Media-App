import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/drawer.dart';
import 'package:social_app/components/post.dart';
import 'package:social_app/components/text_field.dart';
import 'package:social_app/helper/format_date.dart';
import 'package:social_app/pages/chat_home_page.dart';
import 'package:social_app/pages/profile_page.dart';
import 'package:social_app/pages/settings_page.dart';
import 'package:social_app/services/auth/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //get auth service & instance of firestore
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //text controller
  final _textController = TextEditingController();

  //sign user out
  void signOut() {
    _authService.signOut();
  }

  //post message
  void postMessage() {
    //only post if there is something in text field
    if (_textController.text.isNotEmpty) {
      _firestore.collection("User Posts").add({
        "UserEmail": _authService.getCurrentUser()!.email,
        "Message": _textController.text,
        "TimeStamp": Timestamp.now(),
        "Likes": [],
      });
    }

    //clear the text field
    setState(() {
      _textController.clear();
    });
  }

  //navigator to profile page
  void goToProfilePage() {
    //pop menu drawer
    Navigator.pop(context);

    //go to profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  //navigator to chat home page
  void goToChatHomePage() {
    //pop menu drawer
    Navigator.pop(context);

    //go to chat home page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatHomePage(),
      ),
    );
  }

  //navigator to settings page
  void goToSettingsPage() {
    //pop menu drawer
    Navigator.pop(context);

    //go to settings page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //color of the app's background
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Social Media App",
          ),
        ),
      ),

      //drawer
      drawer: MyDrawer(
        onProfile: goToProfilePage,
        onChatHome: goToChatHomePage,
        onSettings: goToSettingsPage,
        onSignOut: signOut,
      ),

      body: Center(
        child: Column(
          children: [
            //app
            Expanded(
              child: StreamBuilder(
                stream: _firestore
                    .collection("User Posts")
                    .orderBy(
                      "TimeStamp",
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshots) {
                  if (snapshots.hasData) {
                    return ListView.builder(
                      itemCount: snapshots.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get the message
                        final post = snapshots.data!.docs[index];
                        return Post(
                          message: post["Message"],
                          user: post["UserEmail"],
                          time: formatDate(post["TimeStamp"]),
                          postId: post.id,
                          likes: List<String>.from(
                            post["Likes"] ?? [],
                          ),
                        );
                      },
                    );
                  } else if (snapshots.hasError) {
                    return Center(
                      child: Text("Error: ${snapshots.error}"),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            //post message
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
                    ),
                  ),

                  //post button
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(
                      Icons.arrow_circle_up,
                    ),
                  ),
                ],
              ),
            ),

            //logged in as
            Text(
              "Logged in as: ${_authService.getCurrentUser()!.email!}",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
