import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nasaspaceapps/auth/signup.dart';
import 'package:nasaspaceapps/pages/addProduct.dart';
import 'package:nasaspaceapps/pages/add_friend.dart';
import 'package:nasaspaceapps/pages/cam.dart';
import 'package:nasaspaceapps/pages/cart.dart';
import 'package:nasaspaceapps/pages/friend_req.dart';
import 'package:nasaspaceapps/pages/friends.dart';
import 'package:nasaspaceapps/pages/gemini.dart';
import 'package:nasaspaceapps/pages/home.dart';
import 'package:nasaspaceapps/pages/posts.dart';
import 'package:nasaspaceapps/pages/shop.dart';
import 'package:nasaspaceapps/services/clock.dart';
import 'package:nasaspaceapps/services/date.dart';
import 'package:nasaspaceapps/services/getcity.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth package

class First extends StatefulWidget {
  const First({super.key});

  @override
  State<First> createState() => _FirstState();
}

class _FirstState extends State<First> {
  String username = "Loading..."; // Default value while loading
  String? profileImageUrl; // Variable to hold the profile image URL

  @override
  void initState() {
    super.initState();
    fetchUsername(); // Fetch username when the widget is initialized
    fetchProfilePicture(); // Fetch profile picture URL

  }
Future<void> fetchProfilePicture() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users') // Your users collection
          .doc(user.uid) // Document ID is the user's UID
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>?; // Ensure type safety
        if (data != null && data.containsKey('profile_picture')) {
          setState(() {
            profileImageUrl = data['profile_picture']; // Fetch the profile picture URL
          });
        }
      }
    } catch (e) {
      print("Error fetching profile picture: $e");
    }
  }
}

  Future<void> fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users') // Your users collection
            .doc(user.uid) // Document ID is the user's UID
            .get();

        if (snapshot.exists) {
          var data =
              snapshot.data() as Map<String, dynamic>?; // Ensure type safety
          if (data != null && data.containsKey('username')) {
            setState(() {
              username = data['username'] ?? "No username"; // Fetch username
            });
          } else {
            setState(() {
              username =
                  "Username not found"; // Handle case where username field does not exist
            });
          }
        } else {
          setState(() {
            username =
                "User not found"; // Handle case where user document does not exist
          });
        }
      } catch (e) {
        setState(() {
          username =
              "Error fetching username"; // Handle any errors that occur during fetching
        });
        print(
            "Error fetching username: $e"); // Print the error to the console for debugging
      }
    } else {
      setState(() {
        username =
            "User not logged in"; // Handle case where no user is logged in
      });
    }
  }

  Widget _buildImageButton(BuildContext context, String imagePath, String label,
      VoidCallback onPressed) {
    return Column(
      children: [
        RawMaterialButton(
          onPressed: onPressed,
          elevation: 2.0, // Add some elevation if you want a shadow
          shape: CircleBorder(), // Make the button circular
          padding: EdgeInsets.zero, // Remove padding
          constraints:
              BoxConstraints.tightFor(width: 50, height: 50), // Set fixed size
          child: ClipOval(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: 50,
              height: 50,
            ),
          ),
        ),
        SizedBox(height: 8), // Space between the button and the text
        Text(label,
            style: TextStyle(
                color: Colors.white, fontSize: 10)), // Display the label
      ],
    );
  }
Future<void> _pickAndUploadImage() async {
  final picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      String filePath = 'users/$uid/profile_picture.png';

      File imageFile = File(pickedFile.path);
      try {
        await FirebaseStorage.instance.ref(filePath).putFile(imageFile);
        
        // Get the download URL
        String downloadUrl = await FirebaseStorage.instance.ref(filePath).getDownloadURL();
        
        // Update Firestore with the download URL
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'profile_picture': downloadUrl,
        });

        // Update the local state variable
        setState(() {
          profileImageUrl = downloadUrl; // Update the profileImageUrl
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile picture updated!')));
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }
}

Widget _buildProfileImagePicker() {
  return GestureDetector(
    onTap: _pickAndUploadImage, // Call the method when tapped
    child: CircleAvatar(
      radius: 20, // Adjust the radius as needed
      backgroundColor: Colors.grey[300], // Default color while loading
      backgroundImage: profileImageUrl != null 
          ? NetworkImage(profileImageUrl!) // Load the existing profile picture
          : null, // Use null if there is no URL
      child: profileImageUrl == null 
          ? Icon(Icons.camera_alt, color: Colors.white) // Show camera icon if no image
          : null, // No icon if an image is present
    ),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              DrawerHeader(child: Container()),
              ListTile(
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => FriendRequestsPage()),
                  );
                },
                title: Text("FRIEND REQUESTS"),
              ),
              
              
              ListTile(
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ShoppingPage()),
                  );
                },
                title: Text("Shop"),
              ),
              ListTile(
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => StorePage()),
                  );
                },
                title: Text("Upload Your Product"),

              ),
              ListTile(
                title: Text("Cart"),
                onTap: (){
                  Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => ShopCartPage()),
);

                },
              ),
              ListTile(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => CreateEmailPage()),
                  );
                },
                title: Text("SIGNOUT"),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/2.png", // Replace with your background image path
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              // Row to hold the drawer button and username
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start, // Align items to the edges
                  children: [
                    Builder(
                      builder: (context) {
                        return IconButton(
                          icon: Icon(Icons.menu,
                              color: Colors.white), // Drawer button
                          onPressed: () {
                            Scaffold.of(context)
                                .openDrawer(); // Open the drawer
                          },
                        );
                      },
                    ),
                    _buildProfileImagePicker(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10,0,0,0),
                      child: Text(
                        username,
                        style: TextStyle(
                            color: Colors.white, fontSize: 18), // Username text
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              DigitalClockScreen(),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                                child: DateDisplayScreen(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset("assets/images/placeholder.png"),
                                LocationExample(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: double.infinity, // To take full width
                    child: Image.asset(
                      "assets/images/q.gif", // Replace with the GIF with a transparent background
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3, // Number of columns
                  mainAxisSpacing: 15, // Space between rows
                  crossAxisSpacing: 15, // Space between columns
                  children: [
                    // First icon and text
                    _buildImageButton(
                      context,
                      "assets/images/addfriend.png",
                      "Add Friend",
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) => AddFriend())),
                    ),
                    // Second icon and text
                    _buildImageButton(
                      context,
                      "assets/images/camera.png",
                      "Detect Diseases",
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CameraPage())),
                    ),
                    // Third icon and text
                    _buildImageButton(
                      context,
                      "assets/images/y.png",
                      "Explore Your Region",
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyHomePage())),
                    ),
                    // Fourth icon and text
                    _buildImageButton(
                      context,
                      "assets/images/hop.png",
                      "Chatbot",
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ChatScreen()),
                        );
                      },
                    ),
                    // Fifth icon and text
                    _buildImageButton(
                      context,
                      "assets/images/post.png",
                      "Posts",
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => PostsPage()),
                        );
                      },
                    ),
                    // Sixth icon and text
                    _buildImageButton(
                      context,
                      "assets/images/friend.png",
                      "Community Hub",
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => FriendsPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
