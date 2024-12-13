import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_app/components/comment.dart';
import 'package:social_app/components/comment_button.dart';
import 'package:social_app/components/delete_button.dart';
import 'package:social_app/components/like_button.dart';
import 'package:social_app/helper/format_date.dart';
import 'package:social_app/services/auth/auth_service.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  const Post({
    super.key,
    required this.message,
    required this.user,
    required this.time,
    required this.postId,
    required this.likes,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  //get auth service & instance of firestore
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //initialize the liked value
  bool _isLiked = false;

  //comment text controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.likes.contains(_authService.getCurrentUser()!.email);
  }

  //toggle like button
  void toggleLikeButton() {
    setState(() {
      _isLiked = !_isLiked;
    });

    //access the document is Firebase
    DocumentReference postRef =
        _firestore.collection("User Posts").doc(widget.postId);

    if (_isLiked) {
      //if the post is now liked, add the user's email to the "Likes" field
      postRef.update({
        "Likes": FieldValue.arrayUnion([_authService.getCurrentUser()!.email])
      });
    } else {
      //if the post is now unliked, remove the user's email to the "Likes" field
      postRef.update({
        "Likes": FieldValue.arrayRemove([_authService.getCurrentUser()!.email])
      });
    }
  }

  //add a comment
  void addComment(String commentText) {
    //write the comment to firestore under the comments collection for this post
    _firestore
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": _authService.getCurrentUser()!.email,
      "CommentTime": Timestamp.now()
    });
  }

  //show a dialog box for adding comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Comment"),
        content: TextField(
          controller: _commentTextController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Write a comment...",
            hintStyle: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ),
        actions: [
          //cancel button
          TextButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);
              //clear controller
              _commentTextController.clear();
            },
            child: const Text("Cancel"),
          ),
          //post button
          TextButton(
            onPressed: () {
              //add comment
              addComment(_commentTextController.text);
              //pop box
              Navigator.pop(context);
              //clear controller
              _commentTextController.clear();
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  //delete a comment
  void deleteComment(DocumentSnapshot commentSnapshot) async {
    //show a dialog box asking for confirmation before deleting the comment
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Comment"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          //cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          //delete button
          TextButton(
            onPressed: () async {
              //delete the comment
              await _firestore
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .doc(commentSnapshot.id)
                  .delete()
                  .then((value) => print("comment deleted"))
                  .catchError(
                      (error) => print("failed to delete comment: $error"));

              //pop the dialog
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  //delete a post
  void deletePost() {
    //show a dialog box asking for confirmation before deleting the post
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          //cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          //delete button
          TextButton(
            onPressed: () async {
              //delete the comments from firestore first
              //(if you only delete the post, the comments will be stored in firestore)
              final commentDocs = await _firestore
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();

              for (var doc in commentDocs.docs) {
                await _firestore
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }

              //then delete the post
              _firestore
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("post deleted"))
                  .catchError(
                      (error) => print("failed to delete post: $error"));

              //pop the dialog
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  //edit post
  Future<void> editPost() async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Post"),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter new message",
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
                  .collection("User Posts")
                  .doc(widget.postId)
                  .update({"Message": newValue});
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  //edit comment
  Future<void> editComment(DocumentSnapshot commentSnapshot) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Comment"),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Enter new comment",
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
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .doc(commentSnapshot.id)
                  .update({"CommentText": newValue});
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //post
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //group of text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //message
                  Text(widget.message),
                  const SizedBox(height: 5),
                  //user
                  Row(
                    children: [
                      Text(
                        widget.user,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        " - ",
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        widget.time,
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              //edit and delete post if that is current user's post
              if (widget.user == _authService.getCurrentUser()!.email)
                Row(
                  children: [
                    //edit post button
                    IconButton(
                      onPressed: editPost,
                      icon: Icon(
                        Icons.settings,
                        color: Colors.grey[400],
                      ),
                    ),

                    //delete post button
                    DeleteButton(
                      onTap: deletePost,
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 20),

          //buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //LIKE
              Column(
                children: [
                  //like button
                  LikeButton(
                    isLiked: _isLiked,
                    onTap: toggleLikeButton,
                  ),
                  const SizedBox(height: 5),
                  //like count
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              //COMMENT
              Column(
                children: [
                  //comment button
                  CommentButton(
                    onTap: showCommentDialog,
                  ),
                  const SizedBox(height: 5),
                  //comment count
                  StreamBuilder<int>(
                    stream: _firestore
                        .collection("User Posts")
                        .doc(widget.postId)
                        .collection("Comments")
                        .snapshots()
                        .map((snapshot) => snapshot.size),
                    builder: (context, snapshot) {
                      //show loading circle if no data yet
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return Text(
                        snapshot.data.toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          //comment under the post
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection("User Posts")
                .doc(widget.postId)
                .collection("Comments")
                .orderBy(
                  "CommentTime",
                  descending: true,
                )
                .snapshots(),
            builder: (context, snapshot) {
              //show loading circle if no data yet
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView(
                shrinkWrap:
                    true, //Wrap content to avoid unnecessary space for nested list
                physics:
                    const NeverScrollableScrollPhysics(), //Disable scrolling if comment list is small
                children: snapshot.data!.docs.map((doc) {
                  //get the comment
                  final commentData = doc.data() as Map<String, dynamic>;

                  //return the comments
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Comment(
                        text: commentData["CommentText"],
                        user: commentData["CommentedBy"],
                        time: formatDate(commentData["CommentTime"]),
                      ),

                      //edit and delete comment if that is current user's comment
                      if (commentData["CommentedBy"] ==
                          _authService.getCurrentUser()!.email)
                        Row(
                          children: [
                            //edit comment button
                            IconButton(
                              onPressed: () => editComment(doc),
                              icon: Icon(
                                Icons.settings,
                                color: Colors.grey[400],
                              ),
                            ),

                            //delete comment button
                            DeleteButton(
                              onTap: () => deleteComment(doc),
                            ),
                          ],
                        ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
