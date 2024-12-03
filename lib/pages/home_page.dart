import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/drawer.dart';
import 'package:social_app/components/post.dart';
import 'package:social_app/components/text_field.dart';
import 'package:social_app/helper/helper_methods.dart';
import 'package:social_app/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text controller
  final textController = TextEditingController();

  //sign user out
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  //post message
  void postMessage() {
    //only post if there is something in text field
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        "UserEmail": currentUser.email,
        "Message": textController.text,
        "TimeStamp": Timestamp.now(),
        "Likes": [],
      });
    }

    //clear the text field
    setState(() {
      textController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        //color of all icon in appbar
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Center(
          child: Text(
            "Social Media App",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.grey[900],
      ),

      //drawer
      drawer: MyDrawer(
        onProfile: goToProfilePage,
        onSignout: signOut,
      ),

      body: Center(
        child: Column(
          children: [
            //app
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy(
                      "TimeStamp",
                      descending: false,
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
                      controller: textController,
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
              "Logged in as: " + currentUser.email!,
              style: TextStyle(
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
