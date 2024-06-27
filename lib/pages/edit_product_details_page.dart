import 'package:flutter/material.dart';
import 'package:mnnit/models/product.dart';

class EditProductDetailsPage extends StatefulWidget {
  final Product product;
  const EditProductDetailsPage({super.key, required this.product});

  @override
  State<EditProductDetailsPage> createState() => _EditProductDetailsPageState();
}

class _EditProductDetailsPageState extends State<EditProductDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
