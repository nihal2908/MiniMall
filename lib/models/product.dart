import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final List<String> images;
  final String details;
  final String description;
  final String category;
  final bool negotiable;
  final String owner;
  final String location;
  final DateTime timestamp;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
    required this.details,
    required this.description,
    required this.category,
    required this.negotiable,
    required this.location,
    required this.owner,
    required this.timestamp,
  });

  factory Product.fromMap({required String id, required Map<String, dynamic> data}) {
    return Product(
      id: id,
      name: data['name'],
      price: data['price'],
      images: List<String>.from(data['images']),
      details: data['details'],
      description: data['description'],
      category: data['category'],
      negotiable: data['negotiable'],
      location: data['location'],
      owner: data['owner'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
