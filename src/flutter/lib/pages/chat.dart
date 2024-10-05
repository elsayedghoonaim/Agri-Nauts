import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String chatId; // ID of the chat thread
  final List<String> users; // List of user IDs in the chat

  const ChatPage({Key? key, required this.chatId, required this.users}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController _scrollController = ScrollController(); // Create ScrollController
  String otherUserName = ''; // To store the username of the other user

  @override
  void initState() {
    super.initState();
    _fetchOtherUserName(); // Fetch the other user's name when the page is initialized
  }

  Future<void> _fetchOtherUserName() async {
    String otherUserId = widget.users.firstWhere((uid) => uid != currentUserId); // Get the other user's ID
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get(); // Fetch the user's document

    if (userDoc.exists) {
      setState(() {
        otherUserName = userDoc['username'] ?? 'Unknown'; // Get the username or set it to 'Unknown'
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(otherUserName.isNotEmpty ? otherUserName : 'Loading...'), // Set the AppBar title to the other user's name
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No messages yet.'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;

                if (data == null || !data.containsKey('messages')) {
                  return const Center(child: Text('Invalid data format.'));
                }

                List<dynamic> messages = data['messages'] ?? [];

                // Scroll to bottom when messages update
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                });

                return ListView.builder(
                  controller: _scrollController, // Pass ScrollController
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index] as Map<String, dynamic>;
                    bool isMe = message['senderId'] == currentUserId;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Only take the width needed
                        children: [
                          Expanded(
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.lightBlue[100] : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(isMe ? 15 : 0),
                                  topRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(isMe ? 0 : 15),
                                  bottomRight: Radius.circular(15),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['text'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    message['senderId'],
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(labelText: 'Type a message'),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      var newMessage = {
        'text': _messageController.text,
        'senderId': currentUserId,
      };

      try {
        DocumentReference chatDoc = FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

        DocumentSnapshot snapshot = await chatDoc.get();

        if (snapshot.exists) {
          List<dynamic> messages = (snapshot.data() as Map<String, dynamic>)['messages'] ?? [];

          messages.add(newMessage);

          await chatDoc.set({
            'messages': messages,
            'users': FieldValue.arrayUnion(widget.users),
          }, SetOptions(merge: true));
        } else {
          await chatDoc.set({
            'messages': [newMessage],
            'users': widget.users,
          });
        }

        // Clear the input field after sending the message
        _messageController.clear(); // Ensure this line is reached
        
        // Scroll to the bottom after sending a message
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }
}
