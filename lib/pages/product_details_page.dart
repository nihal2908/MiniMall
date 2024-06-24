import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mnnit/firebase/firebase_storage.dart';
import 'package:mnnit/models/product.dart';
import 'package:mnnit/widgets/product_tile.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  final String userId; // Add userId to fetch viewing history
  final Firebase storage = Firebase();

  ProductDetailsPage({super.key, required this.product, required this.userId});

  Future<List<Product>> _fetchRecommendations() async {
    final firestore = FirebaseFirestore.instance;

    final docSnapshot = await firestore
        .collection('categories').doc(product.category)
        .get();
    final prods = List<String>.from(docSnapshot.data()!['products']);
    final snap = await firestore.collection('products').where(FieldPath.documentId, whereIn: prods).get();

    return snap.docs.map((prod) {
      final data = prod.data();
      return Product(
        id: prod.id,
        name: data['name'],
        price: data['price'],
        images: List<String>.from(data['images']),
        details: data['details'],
        description: data['description'],
        category: data['category'],
        // Add other fields if necessary
      );
    }).toList();
  }

  Future<List<Product>> _fetchViewingHistory() async {
    final firestore = FirebaseFirestore.instance;

    final userDoc = await firestore.collection('users').doc(userId).get();
    final viewed = Map<String, Timestamp>.from(userDoc['viewed']);

    // Convert the map to a list of entries and sort by timestamp
    final sortedEntries = viewed.entries.toList()
      ..sort((a, b) => (b.value).compareTo(a.value));

    List<String> viewedProductIds = sortedEntries.map((entry) => entry.key).toList();

    // Fetch product details for the viewed product IDs
    final querySnapshot = await firestore
        .collection('products')
        .where(FieldPath.documentId, whereIn: viewedProductIds)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: doc.id,
        name: data['name'],
        price: data['price'],
        images: List<String>.from(data['images']),
        details: data['details'],
        description: data['description'],
        category: data['category'],
        // Add other fields if necessary
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: product.images.map((image) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(image),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('\₹${product.price}', style: const TextStyle(fontSize: 20, color: Colors.green)),
              const SizedBox(height: 10),
              Text(product.details, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(product.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(onPressed: () {
                    storage.addToWishlist(productID: product.id);
                  }, child: const Text('Add to Wishlist')),
                  ElevatedButton(onPressed: () {

                  }, child: const Text('Buy Now')),
                  ElevatedButton(onPressed: () {

                  }, child: const Text('Contact Dealer')),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Recommended Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              FutureBuilder<List<Product>>(
                future: _fetchRecommendations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No recommendations found.'));
                  } else {
                    return Column(
                      children: snapshot.data!.map((product) => ProductTile(product: product)).toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text('Viewing History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              FutureBuilder<List<Product>>(
                future: _fetchViewingHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No viewing history found.'));
                  } else {
                    return Column(
                      children: snapshot.data!.map((product) => ProductTile(product: product)).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
