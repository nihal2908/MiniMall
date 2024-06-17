import 'package:flutter/material.dart';
import 'package:mnnit/models/product.dart';

class ProductDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Product product = ModalRoute.of(context)!.settings.arguments as Product;

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
                      child: Image.asset(image),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Text(product.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('\$${product.price}', style: TextStyle(fontSize: 20, color: Colors.green)),
              SizedBox(height: 10),
              Text(product.details, style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              Text(product.description, style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(onPressed: () {}, child: Text('Add to Wishlist')),
                  ElevatedButton(onPressed: () {}, child: Text('Buy Now')),
                  ElevatedButton(onPressed: () {}, child: Text('Contact Dealer')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
