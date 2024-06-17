import 'package:flutter/material.dart';
import 'package:mnnit/models/product.dart';
import 'package:mnnit/pages/category_page.dart';
import 'package:mnnit/widgets/product_tile.dart';

class HomePage extends StatelessWidget {
  final List<String> categories = ['Bicycles', 'Coolers', 'Fans', 'Tables', 'Stationaries'];
  final List<Product> recentProducts = [
    Product(
      id: '1',
      name: 'Bicycle',
      price: 100.0,
      images: ['assets/bicycle.jpg'],
      details: 'A good bicycle',
      description: 'Used for 1 year, good condition',
    ),
    // Add more products here
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Marketplace'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CategoryPage(category: category,)));
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(category),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Recently Uploaded', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: recentProducts.map((product) => ProductTile(product: product)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
