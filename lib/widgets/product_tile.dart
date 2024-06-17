import 'package:flutter/material.dart';
import 'package:mnnit/models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;

  ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product', arguments: product);
      },
      child: Card(
        child: ListTile(
          leading: Image.asset(product.images[0]),
          title: Text(product.name),
          subtitle: Text('\$${product.price.toString()}'),
        ),
      ),
    );
  }
}
