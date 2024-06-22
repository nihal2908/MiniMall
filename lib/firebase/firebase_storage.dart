import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'firebase_auth.dart';

class Firebase{

  //instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final Auth auth = Auth();

  //functions
  Future<void> addToWishlist(String productID) async {
    try {
      final String uid = await auth.getCurentUser()!.uid;
      await firestore.collection('users').doc(uid).set(
          {'wishlist': FieldValue.arrayUnion([productID])});
    }
    catch(e){
      print(e);
    }
  }

  Future<void> removeFromWishlist(String productID) async {
    try {
      final String uid = await auth.getCurentUser()!.uid;
      await firestore.collection('users').doc(uid).set({
        'wishlist': FieldValue.arrayRemove([productID])
      });
    }
    catch(e){
      print(e);
    }
  }

  Future<void> removeProduct(String productID)async {
    try {
      final String uid = await auth.getCurentUser()!.uid;
      await firestore.collection('products').doc(productID).delete();
      await firestore.collection('users').doc(uid).set({
        'products': FieldValue.arrayRemove([productID])
      });
    }
    catch(e){
      print(e);
    }
  }

  Future<void> removeFromHistory(String productID) async {
    try {
      final String uid = await auth.getCurentUser()!.uid;
      await firestore.collection('users').doc('JRuhTvwywdSeBirkl1tO').update({
        'viewed': FieldValue.arrayRemove([productID])
      });
    }
    catch(e){
      print(e);
    }
  }

  Future<List<String>> uploadImages(List<dynamic> _images) async {
    List<String> imageUrls = [];
    try{
      for (var image in _images) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString()+'.jpg';
        Reference ref = FirebaseStorage.instance.ref().child('images').child(fileName);
        UploadTask uploadTask;

        if (kIsWeb) {
          uploadTask = ref.putData(image);
        } else {
          uploadTask = ref.putFile(image as File);
        }

        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await snapshot.ref.getDownloadURL();
        print(downloadUrl);
        imageUrls.add(downloadUrl);
      }

      // await FirebaseFirestore.instance.collection('images').add({'urls': imageUrls});
      return imageUrls;
    }
    catch(e){
      print(e);
    }
    return imageUrls;
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required String category,
    required String price,
    required String details,
    required List<String> images,
  }) async {
    final String uid = await auth.getCurentUser()!.uid;
    final productDoc = await firestore.collection('products').add({
      'name': name,
      'description': description,
      'details': details,
      'category': category,
      'price': double.parse(price),
      'timestamp': FieldValue.serverTimestamp(),
      'images': images,
      'owner': uid
    });

    await firestore.collection('users').doc(uid).update({
      'products': FieldValue.arrayUnion([productDoc.id])
    });

    await firestore.collection('categories').doc(category).set({
      'name': category,
      'image': images[0],
      'products': FieldValue.arrayUnion([productDoc.id]),
    }, SetOptions(merge: true));
  }

}