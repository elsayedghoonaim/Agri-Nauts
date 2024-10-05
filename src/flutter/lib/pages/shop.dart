import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShoppingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 products per row
              crossAxisSpacing: 10, // Space between columns
              mainAxisSpacing: 10, // Space between rows
              childAspectRatio: 0.75, // Adjust the height of grid items
            ),
            itemCount: products.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;

              return Card(
                elevation: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Product Image
                    Expanded(
                      child: Image.network(
                        product['imageUrl'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Product Title
                    Text(
                      product['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    // Product Subtitle
                    Text(
                      product['subtitle'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    // Add to Cart Button
                    ElevatedButton(
                      onPressed: () async {
                        await _addToCart(
                          product['title'],
                          product['price'],
                          product['imageUrl'],
                        );
                      },
                      child: const Text('Add to Cart'),
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

  // Function to add a product to the user's cart
  Future<void> _addToCart(String title, dynamic price, String imageUrl) async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid; // Get current user's UID

    try {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(currentUserId);
      
      // Get the current cart
      DocumentSnapshot docSnapshot = await userDoc.get();
      List<dynamic> currentCart = (docSnapshot.data() as Map<String, dynamic>)['cart'] ?? [];

      // Check if the item already exists in the cart
      int itemIndex = currentCart.indexWhere((item) => item['name'] == title);
      
      if (itemIndex != -1) {
        // If the item exists, increment the quantity
        currentCart[itemIndex]['quantity'] += 1;

        // Update the total price
        currentCart[itemIndex]['totalPrice'] = currentCart[itemIndex]['price'] * currentCart[itemIndex]['quantity'];
      } else {
        // If the item doesn't exist, add it to the cart with quantity 1
        currentCart.add({
          'name': title,
          'price': price,
          'photo': imageUrl,
          'quantity': 1,
          'totalPrice': price, // Initial total price is the price of one item
        });
      }

      // Update the cart in Firestore
      await userDoc.update({
        'cart': currentCart,
      });

      print('Item added to cart! Current quantity: ${currentCart[itemIndex]['quantity'] ?? 1}');
    } catch (e) {
      print('Error adding to cart: $e');
    }
  }
}
