import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopCartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData == null) {
            return Center(child: Text('User data not found.'));
          }

          List<dynamic> cartItems = (userData['cart'] as List<dynamic>?) ?? [];

          if (cartItems.isEmpty) {
            return Center(child: Text('Your cart is empty.'));
          }

          double totalPrice = 0;
          cartItems.forEach((item) {
            totalPrice += (item['totalPrice'] as num?)?.toDouble() ?? 0.0;
          });

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index] as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 3,
                      child: ListTile(
                        leading: cartItem['photo'] != null
                            ? Image.network(
                                cartItem['photo']!,
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.image_not_supported),
                        title: Text(cartItem['name'] ?? 'Unknown Item'),
                        subtitle: Text('Price: \$${(cartItem['price'] as num?)?.toDouble() ?? 0.0} \nQuantity: ${cartItem['quantity']}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeFromCart(cartItem, currentUserId),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Handle the checkout logic here
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('Proceed to Checkout'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  Future<void> _removeFromCart(Map<String, dynamic> cartItem, String currentUserId) async {
    try {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(currentUserId);
      
      // Get the current cart
      DocumentSnapshot docSnapshot = await userDoc.get();
      List<dynamic> currentCart = (docSnapshot.data() as Map<String, dynamic>)['cart'] ?? [];

      // Remove the item from the cart
      currentCart.removeWhere((item) => item['name'] == cartItem['name']);

      // Update the cart in Firestore
      await userDoc.update({
        'cart': currentCart,
      });

      print('${cartItem['name']} removed from cart!');
    } catch (e) {
      print('Error removing from cart: $e');
    }
  }
}
