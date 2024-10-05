import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final TextEditingController _postController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _addPost() async {
    String currentUserId = _auth.currentUser!.uid;

    if (_postController.text.trim().isNotEmpty) {
      await _firestore.collection('posts').add({
        'authorId': currentUserId,
        'content': _postController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'reactions': {}, // Ensure the 'reactions' field is initialized as an empty map
        'shares': 0,
      });

      _postController.clear();
    }
  }

  Future<void> _toggleReaction(
      DocumentSnapshot postDoc, String reactionType) async {
    String currentUserId = _auth.currentUser!.uid;

    DocumentReference postRef = _firestore.collection('posts').doc(postDoc.id);
    Map<String, dynamic> reactions = (postDoc.data() as Map<String, dynamic>)['reactions'] ?? {};

    if (reactions.containsKey(currentUserId)) {
      // User already reacted, check if it's the same reaction or a new one
      if (reactions[currentUserId] == reactionType) {
        // If same reaction, remove it (toggle off)
        reactions.remove(currentUserId);
      } else {
        // If different reaction, update it
        reactions[currentUserId] = reactionType;
      }
    } else {
      // User hasn't reacted, add reaction
      reactions[currentUserId] = reactionType;
    }

    // Update reactions in Firestore
    await postRef.update({'reactions': reactions});
  }

  // Function to display different reaction counts (like, love, etc.)
  Map<String, int> _countReactions(Map<String, dynamic> reactions) {
    Map<String, int> reactionCounts = {
      'like': 0,
      'love': 0,
      'wow': 0,
    };

    reactions.forEach((userId, reaction) {
      if (reactionCounts.containsKey(reaction)) {
        reactionCounts[reaction] = reactionCounts[reaction]! + 1;
      }
    });

    return reactionCounts;
  }

  void _showComments(BuildContext context, DocumentSnapshot postDoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        TextEditingController commentController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('posts')
                      .doc(postDoc.id)
                      .collection('comments')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No comments yet.'),
                      );
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((commentDoc) {
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(commentDoc['comment']),
                            subtitle: Text(
                                'Commented on ${commentDoc['createdAt'].toDate().toLocal()}'),
                          ),
                        );
                      }).toList(),
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
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        if (commentController.text.trim().isNotEmpty) {
                          await _firestore
                              .collection('posts')
                              .doc(postDoc.id)
                              .collection('comments')
                              .add({
                            'comment': commentController.text.trim(),
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postController,
                    decoration: const InputDecoration(
                      hintText: 'What\'s on your mind?',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addPost,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No posts available.'),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((postDoc) {
                    // Ensure reactions field exists, or use an empty map
                    Map<String, dynamic> reactions = (postDoc.data() as Map<String, dynamic>)['reactions'] ?? {};
                    Map<String, int> reactionCounts = _countReactions(reactions);

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(postDoc['content']),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.thumb_up,
                                        color: reactions[_auth.currentUser!.uid] == 'like'
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      onPressed: () =>
                                          _toggleReaction(postDoc, 'like'),
                                    ),
                                    Text('${reactionCounts['like']}'),
                                    IconButton(
                                      icon: Icon(
                                        Icons.favorite,
                                        color: reactions[_auth.currentUser!.uid] == 'love'
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      onPressed: () =>
                                          _toggleReaction(postDoc, 'love'),
                                    ),
                                    Text('${reactionCounts['love']}'),
                                    IconButton(
                                      icon: Icon(
                                        Icons.face,
                                        color: reactions[_auth.currentUser!.uid] == 'wow'
                                            ? Colors.yellow
                                            : Colors.grey,
                                      ),
                                      onPressed: () =>
                                          _toggleReaction(postDoc, 'wow'),
                                    ),
                                    Text('${reactionCounts['wow']}'),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.comment),
                                  onPressed: () => _showComments(context, postDoc),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
