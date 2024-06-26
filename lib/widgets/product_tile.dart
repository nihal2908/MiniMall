import 'package:flutter/material.dart';
import 'package:mnnit/models/product.dart';
import 'package:mnnit/pages/product_details_page.dart';

class ProductTile extends StatelessWidget {
  final Product product;

  ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailsPage(product: product,)));
      },
      child: Card(
        child: ListTile(
          leading: Image.network(product.images[0]),
          title: Text(product.name),
          subtitle: Text('\₹${product.price}'),
        ),
      ),
    );
  }
}
