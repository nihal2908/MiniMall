import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mnnit/firebase/user_manager.dart';
import 'package:mnnit/models/product.dart';
import 'package:mnnit/widgets/circular_progress.dart';
import 'package:mnnit/widgets/product_tile.dart';

class RecentlyViewedPage extends StatefulWidget {
  const RecentlyViewedPage({super.key});

  @override
  State<RecentlyViewedPage> createState() => _RecentlyViewedPageState();
}

class _RecentlyViewedPageState extends State<RecentlyViewedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recntly viewd'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              FutureBuilder<List<Product>>(
                future: _fetchViewingHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CenterIndicator();
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

  Future<List<Product>> _fetchViewingHistory() async {
    final firestore = FirebaseFirestore.instance;

    final userDoc = await firestore.collection('users').doc(UserManager.userId).get();
    final viewed = Map<String, Timestamp>.from(userDoc['viewed']);

    if(viewed.isEmpty) return [];
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
      return Product.fromMap(
        id: doc.id,
        data: data,
      );
    }).toList();
  }
}
