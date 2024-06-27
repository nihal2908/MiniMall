import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mnnit/firebase/firebase_storage.dart';
import 'package:mnnit/firebase/user_manager.dart';
import 'package:mnnit/models/product.dart';
import 'package:mnnit/pages/chat_room.dart';
import 'package:mnnit/pages/photo_view_page.dart';
import 'package:mnnit/widgets/circular_progress.dart';
import 'package:mnnit/widgets/product_tile.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  final Firebase storage = Firebase();
  String? dealerName;
  bool contact = false;
  bool buy = false;

  ProductDetailsPage({super.key, required this.product,});

  Future<List<Product>> _fetchRecommendations() async {
    final firestore = FirebaseFirestore.instance;
    final DocumentSnapshot docSnapshot = await firestore
        .collection('categories').doc(product.category).get();

    final List<String> prods = List<String>.from(docSnapshot['products']);
    print(prods.toString());
    print('jdhf');
    final snap = await firestore.collection('products').where(FieldPath.documentId, whereIn: prods).get();

    return snap.docs.map((prod) {
      final data = prod.data();
      return Product.fromMap(
        id: prod.id,
        data: data,
      );
    }).toList();
  }

  Future<List<Product>> _fetchViewingHistory() async {
    final firestore = FirebaseFirestore.instance;

    final userDoc = await firestore.collection('users').doc(UserManager.userId).get();
    final viewed = Map<String, Timestamp>.from(userDoc['viewed']);
    if((userDoc as Map<String, dynamic>).containsKey('wishlist'))
    final liked = userDoc['wishlist'] as List<String>;

    // adding current prod to history
    await storage.addToHistory(productID: product.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(onPressed: () async {
            await storage.addToWishlist(productID: product.id);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added to Wishlist')));
          }, icon: Icon(Icons.favorite_border))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
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
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context)=>ImageGallery(
                                    imageUrls: product.images,
                                    initialIndex: product.images.indexOf(image),
                                  ),
                              ),
                          );
                        },
                        child: Image.network(image)
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('\₹${product.price}', style: const TextStyle(fontSize: 20, color: Colors.green)),
              const SizedBox(height: 10),
              Text(product.description, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      buy ? CenterIndicator() : ElevatedButton(onPressed: () {

                      }, child: const Text('Buy Now')),
                      contact ? CenterIndicator() :
                      ElevatedButton(onPressed: () async {
                        setState((){
                          contact = true;
                        });
                        final data = await storage.getDealerData(dealerId: product.owner);
                        dealerName = data['name'];
                        setState((){
                          contact = false;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoomPage(recieverId: product.owner, name: dealerName!)));
                      }, child: const Text('Contact Dealer')),
                    ],
                  );
                }
              ),
              const SizedBox(height: 20),
              const Text('Recommended Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              FutureBuilder<List<Product>>(
                future: _fetchRecommendations(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CenterIndicator();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data==null ||snapshot.data!.isEmpty) {
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
}
