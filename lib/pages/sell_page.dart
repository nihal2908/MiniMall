import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/firebase/user_manager.dart';
import 'package:mnnit/models/product.dart';
import 'package:mnnit/pages/add_product_page.dart';
import 'package:mnnit/widgets/circular_progress.dart';
import 'package:mnnit/widgets/product_tile.dart';

class SellPage extends StatelessWidget {
  SellPage({super.key});
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddProductPage()));
            },
            icon: const Icon(Icons.add_box),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: FutureBuilder<DocumentSnapshot>(
            future: firestore.collection('users').doc(UserManager.userId).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CenterIndicator();
              }
              if (snapshot.hasError) {
                return ListTile(
                  title: Text('Error: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const ListTile(
                  title: Text(
                    'You have not added any item to your Selling list. '
                        'Tap the \'Add\' button to add items now.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final List<dynamic> productIds = data['products'] ?? [];

              return Column(
                children: productIds.map((productId) {
                  return FutureBuilder<DocumentSnapshot>(
                    future: firestore.collection('products').doc(productId).get(),
                    builder: (context, snapshot2) {
                      if (snapshot2.connectionState == ConnectionState.waiting) {
                        return CenterIndicator();
                      }
                      if (snapshot2.hasError) {
                        return ListTile(
                          title: Text('Error: ${snapshot2.error}'),
                        );
                      }
                      if (!snapshot2.hasData || !snapshot2.data!.exists) {
                        return ListTile(
                          title: Text('Product not found'),
                        );
                      }

                      final productData = snapshot2.data!.data() as Map<String, dynamic>;
                      final Product product = Product.fromMap(
                        id: productId,
                        data: productData
                      );

                      return ProductTile(product: product);
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}