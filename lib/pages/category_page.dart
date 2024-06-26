import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mnnit/models/product.dart';
import 'package:mnnit/widgets/product_tile.dart';

class CategoryPage extends StatelessWidget {
  final String category;

  const CategoryPage({super.key, required this.category});

  Future<List<Product>> _fetchProductsByCategory() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch the category document to get the list of product IDs
    final DocumentSnapshot categoryDoc = await firestore.collection('categories').doc(category).get();
    final List<String> productIds = List<String>.from(categoryDoc['products']);

    // Fetch the products using the product IDs
    final QuerySnapshot productsSnapshot = await firestore
        .collection('products')
        .where(FieldPath.documentId, whereIn: productIds)
        .get();

    return productsSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Product.fromMap(
        id: doc.id,
        data: data,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: FutureBuilder<List<Product>>(
        future: _fetchProductsByCategory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found.'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return ProductTile(product: products[index]);
              },
            );
          }
        },
      ),
    );
  }
}
