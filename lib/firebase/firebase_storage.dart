import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mnnit/firebase/user_manager.dart';
import 'firebase_auth.dart';

class Firebase{

  //instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final Auth auth = Auth();

  //functions
  Future<void> addToWishlist({required String productID}) async {
    try {
      // final String uid = await auth.getCurentUser()!.uid;
      await firestore.collection('users').doc(UserManager.userId).update({
        'wishlist': FieldValue.arrayUnion([productID])
      });
    }
    catch(e){
      print(e);
    }
  }

  Future<void> removeFromWishlist({required String productID}) async {
    try {
      // final String uid = await auth.getCurentUser()!.uid;
      await firestore.collection('users').doc(UserManager.userId).update({
        'wishlist': FieldValue.arrayRemove([productID])
      });
    }
    catch(e){
      print(e);
    }
  }

  Future<void> addToHistory({required String productID}) async {
    try {
      // final String uid = await auth.getCurentUser()!.uid;
      await firestore.collection('users').doc(UserManager.userId).update({
        'viewed.${productID}': FieldValue.serverTimestamp(),
      });
    }
    catch(e){
      print(e);
    }
  }

  Future<void> removeFromHistory({required String productID}) async {
    try {
      // final String uid = await auth.getCurentUser()!.uid;
      await firestore.collection('users').doc(UserManager.userId).update({
        'viewed': FieldValue.arrayRemove([productID])
      });
    }
    catch(e){
      print(e);
    }
  }


  Future<void> deleteProduct({required String productID})async {
    try {
      // final String uid = await auth.getCurentUser()!.uid;
      await firestore.collection('products').doc(productID).delete();
      await firestore.collection('users').doc(UserManager.userId).update({
        'products': FieldValue.arrayRemove([productID])
      });
    }
    catch(e){
      print(e);
    }
  }

  Future<void> hideProduct({required String productID})async {
    try {
      // final String uid = await auth.getCurentUser()!.uid;
      await firestore.collection('products').doc(productID).update({
        'status': 'hidden'
      });
      // await firestore.collection('users').doc(UserManager.userId).update({
      //   'products': FieldValue.arrayRemove([productID])
      // });
    }
    catch(e){
      print(e);
    }
  }

  Future<void> updateProduct({
    required String productID,
    required String name,
    required double price,
    required String description,
    required bool negotiable,
    required String location,
    required List<String> images,
  }) async {
    try {
      // final String uid = await auth.getCurentUser()!.uid;
      await firestore.collection('products').doc(productID).update({
        'name': name,
        'description': description,
        'price': price,
        'negotiable': negotiable,
        'location': location,
        'images': images,
        'edited': true
      });
    }
    catch(e){
      print(e);
    }
  }

  Future<void> addProduct({
    required String name,
    required String description,
    required String category,
    required String price,
    required bool negotiable,
    required String location,
    required List<String> images,
  }) async {
    // final String uid = await auth.getCurentUser()!.uid;
    final productDoc = await firestore.collection('products').add({
      'name': name,
      'description': description,
      'category': category,
      'price': double.parse(price),
      'negotiable': negotiable,
      'timestamp': FieldValue.serverTimestamp(),
      'location': location,
      'images': images,
      'status': 'unsold',
      'views': 0,
      'owner': UserManager.userId
    });

    await firestore.collection('users').doc(UserManager.userId).update({
      'products': FieldValue.arrayUnion([productDoc.id])
    });

    await firestore.collection('categories').doc(category).set({
      'name': category,
      'image': images[0],
      'products': FieldValue.arrayUnion([productDoc.id]),
    }, SetOptions(merge: true));
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

}