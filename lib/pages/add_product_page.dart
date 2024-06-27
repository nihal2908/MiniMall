// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mnnit/firebase/firebase_storage.dart';
import 'package:mnnit/pages/landing_page.dart';
import 'package:mnnit/widgets/circular_progress.dart';
import 'package:mnnit/widgets/custom_textformfield.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController name = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController description = TextEditingController();
  // ignore: non_constant_identifier_names
  final TextEditingController new_category = TextEditingController();
  final TextEditingController location = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  // ignore: prefer_final_fields
  List<File> _images = [];
  // ignore: unused_field
  bool _isUploading = false;
  List<String> _uploadedImageUrls = [];
  String category = '';
  List<String> categories = [];
  bool fixed_price = false;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    final firestore = FirebaseFirestore.instance;
    final querySnapshot = await firestore.collection('categories').get();
    setState(() {
      categories = querySnapshot.docs.map((doc) => doc.id).toList();
      categories.add('Other(Specify)');
      category = categories[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              if (_images.isNotEmpty) SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: _images.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Stack(
                        children: [
                          Image.file(_images[index], fit: BoxFit.cover),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
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
              IconButton(
                onPressed: _pickImage,
                icon: const Column(
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 60,
                      color: Colors.white,
                    ),
                    Text('Add Product Image', style: TextStyle(color: Colors.white),)
                  ],
                ),

              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextFormField(
                labelText: 'Name',
                controller: name,
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                value: category.isNotEmpty ? category : null,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: '',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                items: categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    category = value!;
                    if (value == 'Other(Specify)') {
                      new_category.clear();
                    } else {
                      new_category.text = value;
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              if (category == 'Other(Specify)')
                CustomTextFormField(
                  labelText: 'Category',
                  controller: new_category,
                  validator: (value) {
                    return null;
                  },
                ),
              if (category == 'Other')
                const SizedBox(
                  height: 10,
                ),
              CustomTextFormField(
                labelText: 'Description',
                controller: description,
                maxlines: null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required filed';
                  } else if (value.length > 2000) {
                    return 'Text is too large';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextFormField(
                labelText: 'Location',
                controller: location,
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextFormField(
                labelText: 'Price',
                controller: price,
                keyboard: TextInputType.number,
                validator: (value) {
                  if (value == null) {
                    return 'Required field';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ChoiceChip(
                    label: const Text('Fixed Price'),
                    selected: fixed_price,
                    onSelected: (value) {
                      setState(() {
                        fixed_price = value;
                      });
                    },
                    selectedColor: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  showProgress(context);
                  final Firebase storage = Firebase();
                  await _uploadImages().then((value) async {
                    _uploadedImageUrls = value;
                    await storage.addProduct(
                        name: name.text,
                        category: new_category.text.isNotEmpty
                            ? new_category.text
                            : category,
                        price: price.text,
                        negotiable: fixed_price,
                        description: description.text,
                        location: location.text,
                        images:
                            _uploadedImageUrls //imageControllers.map((image) => image.text).toList(),
                        );
                  });
                  Navigator.pop(context);
                  showDone(context);
                },
                child: const Text('Save'),
              ),
              // TextButton(
              //     onPressed: () {
              //       Navigator.pushReplacement(context,
              //           MaterialPageRoute(builder: (context) => LandingPage()));
              //     },
              //     child: Text('back'))
            ],
          ),
        ),
      ),
    );
  }

  // Future<void> _pickImage() async {
  //   try {
  //     final pickedFiles = await _picker.pickMultiImage(limit: 5, imageQuality: 50);
  //     if (pickedFiles != null) {
  //       setState(() {
  //         _images.addAll(
  //             pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
  //       });
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Error picking images: $e')));
  //   }
  // }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final pickedFiles = await _picker.pickMultiImage(limit: 5, imageQuality: 70);
                    if (pickedFiles != null) {
                      setState(() {
                        _images.addAll(
                            pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error picking images: $e')));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    final pickedFile = await _picker.pickImage(source: ImageSource.camera,imageQuality: 50);
                    if (pickedFile != null) {
                      setState(() {
                        _images.add(File(pickedFile.path));
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>> _uploadImages() async {
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('No images selected')));
      return [];
    }

    setState(() {
      _isUploading = true;
    });
    List<String> imageUrls = [];
    try {
      for (File image in _images) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref =
            FirebaseStorage.instance.ref().child('images').child(fileName);
        UploadTask uploadTask;

        uploadTask = ref.putFile(image);

        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // await FirebaseFirestore.instance.collection('images').add({'urls': imageUrls});

      setState(() {
        _isUploading = false;
        _images.clear();
        // _uploadedImageUrls = imageUrls;
      });

      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Images uploaded successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading images: $e'),
        ),
      );
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading images'),
        ),
      );
    }
    return imageUrls;
  }

  void showProgress(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Uploading...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CenterIndicator(
                  color: Colors.deepPurple,
                ),
              ],
            ),
          );
        },
        barrierDismissible: false);
  }

  void showDone(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Successfully Added'),
            content: const Text('Refresh your Products Page to sync changes'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LandingPage(initialPage: 2),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.green),
                  )),
            ],
          );
        });
  }
}
