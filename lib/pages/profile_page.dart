import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/text_box.dart';
import 'package:social_app/helper/format_date.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //current user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //all users
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  //edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(
              color: Colors.grey,
            ),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          //cancer button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          //save button
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: const Text(
              "Save",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    //update in firestore
    if (newValue.trim().isNotEmpty) {
      //only update if there is something in the text field
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
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
        title: const Center(
          child: Text(
            "Profile Page",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshots) {
          if (snapshots.hasData) {
            final userData = snapshots.data!.data() as Map<String, dynamic>;
            return ListView(
              children: [
                const SizedBox(height: 50),

                //profile pic
                const Icon(
                  Icons.person,
                  size: 72,
                ),

                const SizedBox(height: 10),

                //user email
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 50),

                //user details
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    "My Details",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

                //email
                MyTextBox(
                  text: userData["email"],
                  sectionName: "email",
                  onPressed: () => Navigator.pop(context),
                ),

                //username
                MyTextBox(
                  text: userData["username"],
                  sectionName: "username",
                  onPressed: () => editField("username"),
                ),

                //bio
                MyTextBox(
                  text: userData["bio"],
                  sectionName: "bio",
                  onPressed: () => editField("bio"),
                ),

                const SizedBox(height: 50),

                //user's posts
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    "My Posts",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),

                //posts overview
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .where("UserEmail", isEqualTo: currentUser.email)
                      .snapshots(),
                  builder: (context, snapshots) {
                    if (snapshots.hasData) {
                      final posts = snapshots.data!.docs;

                      //Filter and sort posts on the client-side
                      final filteredPosts = posts
                          .where((doc) => doc['UserEmail'] == currentUser.email)
                          .toList();
                      filteredPosts.sort((a, b) => a['TimeStamp']
                          .compareTo(b['TimeStamp'])); //TimeStamp descending

                      return ListView.builder(
                        shrinkWrap:
                            true, //Wrap content to avoid unnecessary space for nested list
                        physics:
                            const NeverScrollableScrollPhysics(), //Disable scrolling if comment list is small
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          final postData = filteredPosts[index].data()
                              as Map<String, dynamic>;
                          //show posts
                          return MyTextBox(
                            text: postData["Message"],
                            sectionName: formatDate(postData["TimeStamp"]),
                            onPressed: () => Navigator.pop(context),
                          );
                        },
                      );
                    } else if (snapshots.hasError) {
                      return Text("Error: ${snapshots.error}");
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                )
              ],
            );
          } else if (snapshots.hasError) {
            return Center(
              child: Text("Error ${snapshots.error}"),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
