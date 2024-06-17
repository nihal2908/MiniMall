import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  
  final String category;
  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {

    // Here you would fetch and display products based on the category
    // For simplicity, this is just a placeholder
    final List<String> items = ['Item 1', 'Item 2', 'Item 3'];

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
          );
        },
      ),
    );
  }
}
