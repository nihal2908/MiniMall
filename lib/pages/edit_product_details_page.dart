import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mnnit/firebase/firebase_storage.dart';
import 'package:mnnit/models/product.dart';
import 'package:mnnit/pages/landing_page.dart';
import 'package:mnnit/widgets/circular_progress.dart';
import 'package:mnnit/widgets/custom_textformfield.dart';
import 'package:mnnit/widgets/snackbar.dart';

class EditProductDetailsPage extends StatefulWidget {
  final Product product;
  const EditProductDetailsPage({super.key, required this.product});

  @override
  State<EditProductDetailsPage> createState() => _EditProductDetailsPageState();
}

class _EditProductDetailsPageState extends State<EditProductDetailsPage> {

  late TextEditingController name;
  late TextEditingController price;
  late TextEditingController description;
  // ignore: non_constant_identifier_names
  late TextEditingController new_category;
  late TextEditingController location;
  late ImagePicker _picker;
  // ignore: prefer_final_fields
  List<File> _images = [];
  List<String>? _uploadedImages;
  // ignore: unused_field
  bool _isUploading = false;
  List<String> _uploadedImageUrls = [];
  bool? fixed_price;

  void initialiseControllers(){
    name = TextEditingController(text: widget.product.name);
    price = TextEditingController(text: widget.product.price.toString());
    description = TextEditingController(text: widget.product.description);
    new_category = TextEditingController(text: widget.product.category);
    location = TextEditingController(text: widget.product.location);
    _picker = ImagePicker();
    _uploadedImages = widget.product.images;
    fixed_price = widget.product.negotiable;
  }

  void disposeControllers(){
    name.dispose();
    description.dispose();
    location.dispose();
    new_category.dispose();
    price.dispose();
  }

  @override
  void initState() {
    initialiseControllers();
    super.initState();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              if (_uploadedImages!=null && _uploadedImages!.isNotEmpty)
              SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  itemCount: _uploadedImages!.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Stack(
                        children: [
                          Image.network(_uploadedImages![index], fit: BoxFit.cover),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _uploadedImages!.removeAt(index);
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
                    Text('Add another image', style: TextStyle(color: Colors.white),)
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
                  if(value==null || value.isEmpty){
                    return 'Required field';
                  }
                  return null;
                },
              ),
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
                    selected: fixed_price!,
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
                  if(_uploadedImages!.isEmpty && _images.isEmpty){
                    showSnackbar(context: context, content: 'You must add atleast one image of product');
                  }
                  else {
                    showProgress(context);
                    final Firebase storage = Firebase();
                    await _uploadImages().then((value) async {
                      _uploadedImages!.addAll(value);
                      await storage.updateProduct(
                          name: name.text,
                          price: double.parse(price.text),
                          negotiable: fixed_price!,
                          description: description.text,
                          location: location.text,
                          images: _uploadedImages!,
                          productID: widget.product.id
                      );
                    });
                    Navigator.pop(context);
                    showDone(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        SnackBar(
          content: Text('Error uploading images: $e'),
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
        barrierDismissible: false,
    );
  }

  void showDone(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Changes saved'),
            content: const Text('Click OK to go back to Your Products.'),
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
        },
      barrierDismissible: false,
    );
  }

}
