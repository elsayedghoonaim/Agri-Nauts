import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nasaspaceapps/pages/chat.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Friends"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .collection('friends')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('You have no friends yet.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var friend = snapshot.data!.docs[index];
              String friendId = friend.id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(friendId).get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: const Text('Loading...'),
                    );
                  }

                  if (userSnapshot.hasError) {
                    return ListTile(
                      title: const Text('Error fetching username'),
                      subtitle: Text(friendId),
                    );
                  }

                  String friendUsername = userSnapshot.data?.get('username') ?? 'Unknown User';

                  return ListTile(
                    title: Text(friendUsername),
                    subtitle: Text(friendId),
                    onTap: () => _openChat(friendId, friendUsername),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _openChat(String userId, String friendUsername) {
    // Sort user IDs to create a consistent chatId
    List<String> users = [currentUserId, userId]..sort();
    String chatId = 'chat_${users[0]}_${users[1]}';
    
    // Navigate to ChatPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(chatId: chatId, users: users),
      ),
    );
  }
}
