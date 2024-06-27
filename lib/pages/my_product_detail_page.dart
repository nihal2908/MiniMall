import 'package:flutter/material.dart';
import 'package:mnnit/models/product.dart';
import 'package:mnnit/pages/photo_view_page.dart';

class MyProductDetailPage extends StatelessWidget {
  final Product product;
  const MyProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
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
            ],
          ),
        ),
      ),
    );
  }
}
