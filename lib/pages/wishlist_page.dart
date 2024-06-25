// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/firebase/firebase_storage.dart';
import 'package:mnnit/widgets/circular_progress.dart';
import 'package:mnnit/models/product.dart';
import 'package:mnnit/firebase/user_manager.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Firebase _firestore = Firebase();

  Future<List<Product>> getWishlistProducts() async {
    try {
      DocumentSnapshot userDoc = await firestore.collection('users').doc(UserManager.userId).get();
      if (userDoc.exists) {
        List<dynamic> wishlist = userDoc['wishlist'] ?? [];
        if (wishlist.isEmpty) {
          return [];
        }
        QuerySnapshot productSnapshot = await firestore.collection('products').where(FieldPath.documentId, whereIn: wishlist).get();
        return productSnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Product(
            id: doc.id,
            name: data['name'],
            price: data['price'],
            images: List<String>.from(data['images']),
            details: data['details'],
            description: data['description'],
            category: data['category'],
          );
        }).toList();
      } else {
        throw Exception('User data not found');
      }
    } catch (e) {
      throw Exception('Error fetching wishlist: $e');
    }
  }

  Future<void> removeFromWishlist(String productId) async {
    try {
      DocumentReference userDocRef = firestore.collection('users').doc(UserManager.userId);
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userDocRef);
        if (userDoc.exists) {
          List<dynamic> wishlist = List.from(userDoc['wishlist']);
          wishlist.remove(productId);
          transaction.update(userDocRef, {'wishlist': wishlist});
        }
      });
    } catch (e) {
      throw Exception('Error removing from wishlist: $e');
    }
  }

  void showDeleteDialog(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Wishlist?'),
        content: const Text('Do you want to remove this product from your wishlist?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // showDialog(context: context, builder: (context) => CenterIndicator());
              // await removeFromWishlist(productId);
              await _firestore.removeFromWishlist(productID: productId);
              // await Future.delayed(Duration(seconds: 5));
              // Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Wishlist'),
      ),
      body: FutureBuilder<List<Product>>(
        future: getWishlistProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CenterIndicator();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Your wishlist is empty.'),
            );
          }
          final wishlistProducts = snapshot.data!;
          return ListView.builder(
            itemCount: wishlistProducts.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: Image.network(wishlistProducts[index].images[0]),
                  title: Text(wishlistProducts[index].name),
                  subtitle: Text('₹${wishlistProducts[index].price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDeleteDialog(context, wishlistProducts[index].id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
