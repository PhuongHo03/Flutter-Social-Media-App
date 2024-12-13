import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/text_box.dart';
import 'package:social_app/helper/format_date.dart';
import 'package:social_app/services/auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //get auth service & instance of firestore
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Edit $field",
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(
              color: Colors.grey[500],
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
            child: const Text("Cancel"),
          ),

          //save button
          TextButton(
            onPressed: () async {
              //update in firestore
              await _firestore
                  .collection("Users")
                  .doc(_authService.getCurrentUser()!.email)
                  .update({field: newValue});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Profile Page",
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection("Users")
            .doc(_authService.getCurrentUser()!.email)
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
                  _authService.getCurrentUser()!.email!,
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
                  stream: _firestore
                      .collection("User Posts")
                      .where("UserEmail",
                          isEqualTo: _authService.getCurrentUser()!.email)
                      .snapshots(),
                  builder: (context, snapshots) {
                    if (snapshots.hasData) {
                      final posts = snapshots.data!.docs;

                      //Filter and sort posts on the client-side
                      final filteredPosts = posts
                          .where((doc) =>
                              doc['UserEmail'] ==
                              _authService.getCurrentUser()!.email)
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
