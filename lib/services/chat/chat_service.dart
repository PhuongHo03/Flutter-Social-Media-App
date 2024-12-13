import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/models/message.dart';
import 'package:social_app/services/auth/auth_service.dart';

class ChatService {
  //get auth service & instance of firestore
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        //go through each individual user
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  //send message
  Future<void> sendMessage(String receiverID, message) async {
    //get current user info
    final String currentUserID = _authService.getCurrentUser()!.uid;
    final String currentUserEmail = _authService.getCurrentUser()!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    //construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); //sort the ids (this ensure the chatRoomID is the same for any 2 people)
    String chatRoomID = ids.join('_');

    //add new message to database
    await _firestore
        .collection("Chat Rooms")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
  }

  //get messages
  Stream<QuerySnapshot> getMessages(String senderID, receiverID) {
    //construct a chatRoomID for the two users
    List<String> ids = [senderID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("Chat Rooms")
        .doc(chatRoomID)
        .collection("Messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
