import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  final ImagePicker _picker = ImagePicker();
  List<dynamic> _images = []; // List of files for mobile, List of bytes for web
  bool _isUploading = false;
  List<String> _uploadedImageUrls = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Stack(
                    children: [
                      kIsWeb
                          ? Image.memory(_images[index], fit: BoxFit.cover)
                          : Image.file(_images[index] as File, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _images.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Add Image'),
          ),
          SizedBox(height: 20),
          _isUploading
              ? CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _uploadImages,
            child: Text('Save'),
          ),
          SizedBox(height: 20),
          SizedBox(height: 20),
          if (_uploadedImageUrls.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _uploadedImageUrls.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Image.network(_uploadedImageUrls[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        final pickedFiles = await _picker.pickMultiImage();
        if (pickedFiles != null) {
          for (var pickedFile in pickedFiles) {
            Uint8List bytes = await pickedFile.readAsBytes();
            setState(() {
              _images.add(bytes);
            });
          }
        }
      } else {
        final pickedFiles = await _picker.pickMultiImage();
        if (pickedFiles != null) {
          setState(() {
            _images.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
          });
        }
      }
    } catch (e) {
      print('Error picking images: $e');
    }
  }

  Future<void> _uploadImages() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No images selected')));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      List<String> imageUrls = [];
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

      await FirebaseFirestore.instance.collection('images').add({'urls': imageUrls});

      setState(() {
        _isUploading = false;
        _images.clear();
        _uploadedImageUrls = imageUrls;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Images uploaded successfully')));
    } catch (e) {
      print('Error uploading images: $e');
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading images')));
    }
  }
}
