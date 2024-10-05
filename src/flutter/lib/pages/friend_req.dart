import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({Key? key}) : super(key: key);

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Friend Requests"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('friend_requests')
            .where('to', isEqualTo: currentUserId)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No friend requests.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var request = snapshot.data!.docs[index];
              String fromUserId = request['from'];
              String requestId = request.id;

              return ListTile(
                title: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(fromUserId).get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return Text('Loading...');
                    }
                    if (userSnapshot.hasError) {
                      return Text('Error: ${userSnapshot.error}');
                    }
                    String friendUsername = userSnapshot.data!['username'] ?? 'Unknown User';
                    return Text('Friend request from: $friendUsername ($fromUserId)');
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      color: Colors.white,
                      onPressed: () => acceptRequest(requestId, fromUserId),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      color: Colors.red,
                      onPressed: () => declineRequest(requestId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> acceptRequest(String requestId, String fromUserId) async {
    try {
      // Fetch the sender's username from Firestore
      var userSnapshot = await FirebaseFirestore.instance.collection('users').doc(fromUserId).get();
      String friendUsername = userSnapshot['username']; // Assuming 'username' field exists

      // Update the status of the request
      await FirebaseFirestore.instance
          .collection('friend_requests')
          .doc(requestId)
          .update({'status': 'accepted'});

      // Add friend to both users' friends collections
      await _addFriend(currentUserId, fromUserId, friendUsername);
      await _addFriend(fromUserId, currentUserId, FirebaseAuth.instance.currentUser!.displayName ?? "Unknown User");

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request accepted from $friendUsername.')),
      );

      // Optionally, navigate to a friends list page or refresh the current page
      // Navigator.of(context).pushReplacement(...); // Example navigation
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting request: ${e.toString()}')),
      );
    }
  }

  Future<void> _addFriend(String userId, String friendId, String friendUsername) async {
    try {
      // Create a friends collection in each user's document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .set({
            'username': friendUsername,
            'friendId': friendId,
          });
    } catch (e) {
      print('Error adding friend: ${e.toString()}');
    }
  }

  Future<void> declineRequest(String requestId) async {
    // Delete the friend request
    await FirebaseFirestore.instance
        .collection('friend_requests')
        .doc(requestId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request declined.')),
    );
  }
}
