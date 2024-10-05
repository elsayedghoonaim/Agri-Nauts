import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriend extends StatefulWidget {
  const AddFriend({Key? key}) : super(key: key);

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  final TextEditingController _controller = TextEditingController();
  String? _userId;
  String? _userName;
  bool _userFound = false;
  bool _isRequested = false;
  bool _isFriend = false;

  Future<void> searchUser() async {
    String numericId = _controller.text.trim();

    // Query Firestore for the user by numeric_id
    var userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('numeric_id', isEqualTo: int.tryParse(numericId))
        .limit(1)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      Map<String, dynamic> userData = userSnapshot.docs.first.data() as Map<String, dynamic>;

      setState(() {
        _userId = userSnapshot.docs.first.id; // Get the document ID (user UID)
        _userName = userData['username']; // Get the username
        _userFound = true;
      });

      // Check if the user is already a friend
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var friendSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(_userId) // Check if this user is already a friend
          .get();

      // Check if there's already a friend request sent
      var requestSnapshot = await FirebaseFirestore.instance
          .collection('friend_requests')
          .where('from', isEqualTo: currentUserId)
          .where('to', isEqualTo: _userId)
          .get();

      setState(() {
        _isFriend = friendSnapshot.exists; // Check if already friends
        _isRequested = requestSnapshot.docs.isNotEmpty; // Check if request is already sent
      });

      print('User found: $_userName with ID: $_userId');
    } else {
      setState(() {
        _userFound = false;
        _userId = null;
        _userName = null;
        _isFriend = false;
        _isRequested = false;
      });

      print('No user found with numeric ID: $numericId');
    }
  }

  Future<void> sendFriendRequest() async {
    if (_userId != null) {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Send a friend request
      await FirebaseFirestore.instance.collection('friend_requests').add({
        'from': currentUserId, // The user sending the request
        'to': _userId, // The user receiving the request
        'status': 'pending', // Initial status
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to $_userName')),
      );

      setState(() {
        _isRequested = true; // Update the UI
      });

      _controller.clear();
      setState(() {
        _userFound = false; // Reset the search
      });
    }
  }

  Future<void> removeFriendRequest() async {
    // Remove the pending friend request
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    var requestSnapshot = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('from', isEqualTo: currentUserId)
        .where('to', isEqualTo: _userId)
        .get();

    for (var doc in requestSnapshot.docs) {
      await doc.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend request removed')),
    );

    setState(() {
      _isRequested = false; // Update the UI
    });
  }

  Future<void> acceptFriendRequest() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Add friend to the current user's friends collection
    await FirebaseFirestore.instance.collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(_userId) // Friend's document ID
        .set({
      'friendId': _userId,
      'username': _userName,
    });

    // Add the current user to the friend's friends collection
    await FirebaseFirestore.instance.collection('users')
        .doc(_userId)
        .collection('friends')
        .doc(currentUserId) // Current user's document ID
        .set({
      'friendId': currentUserId,
      'username': FirebaseAuth.instance.currentUser!.displayName, // Replace with appropriate field
    });

    // Remove the friend request
    await removeFriendRequest();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You are now friends with $_userName')),
    );

    setState(() {
      _isFriend = true; // Update the UI
      _isRequested = false; // Reset request status
    });
  }

  Future<void> removeFriend() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Remove the friend from the current user's friends collection
    await FirebaseFirestore.instance.collection('users')
        .doc(currentUserId)
        .collection('friends')
        .doc(_userId) // Friend's document ID
        .delete();

    // Remove the current user from the friend's friends collection
    await FirebaseFirestore.instance.collection('users')
        .doc(_userId)
        .collection('friends')
        .doc(currentUserId) // Current user's document ID
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('You are no longer friends with $_userName')),
    );

    setState(() {
      _isFriend = false; // Update the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add Friend"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Numeric ID',
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: searchUser,
              child: const Text('Search'),
            ),
            if (_userFound) ...[
              ListTile(
                title: Text('User Found: $_userName'),
                subtitle: _isFriend
                    ? Row(
                        children: [
                          const Flexible(
                            child: Text('You are friends'),
                          ),
                          const SizedBox(width: 8), // Add some spacing
                          Flexible(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // If the width is less than a certain size, hide the remove button
                                if (constraints.maxWidth < 120) {
                                  return Container(); // If the content overflows, remove the button
                                } else {
                                  return IconButton(
                                    onPressed: removeFriend,
                                    icon: const Icon(Icons.remove),
                                    tooltip: 'Remove Friend',
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      )
                    : (_isRequested
                        ? IconButton(
                            onPressed: removeFriendRequest,
                            icon: const Icon(Icons.cancel),
                            tooltip: 'Remove Request',
                          )
                        : IconButton(
                            onPressed: sendFriendRequest,
                            icon: const Icon(Icons.add),
                            tooltip: 'Send Friend Request',
                          )),
              ),
            ],
            if (!_userFound && _controller.text.isNotEmpty)
              const Text('User not found.', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
