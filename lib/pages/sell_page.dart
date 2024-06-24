import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mnnit/firebase/firebase_storage.dart';
import 'package:mnnit/widgets/circular_progress.dart';

class SellPage extends StatefulWidget {
  SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final TextEditingController name = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController details = TextEditingController();
  final TextEditingController new_category = TextEditingController();
  final TextEditingController location = TextEditingController();

  String category = '';
  List<String> categories = [];
  int n_images = 0;
  List<TextEditingController> imageControllers = [];
  bool negotiable = false;

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
      categories.add('Other');
      category = categories[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sell'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            DropdownButtonFormField<String>(
              value: category.isNotEmpty ? category : null,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              items: categories
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  category = value!;
                  if (value == 'Other') {
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
            if (category == 'Other')
              TextField(
                controller: new_category,
                decoration: InputDecoration(
                  labelText: 'Category',
                ),
              ),
            TextField(
              controller: description,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            TextField(
              controller: details,
              decoration: InputDecoration(
                labelText: 'Details',
              ),
            ),
            TextField(
              controller: location,
              decoration: InputDecoration(
                labelText: 'Location',
              ),
            ),
            TextField(
              controller: price,
              decoration: InputDecoration(
                labelText: 'Price',
              ),
            ),
            SizedBox(height: 10,),
            StatefulBuilder(
              builder: (context, chipState){
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ChoiceChip(
                      label: Text('Negotiable'),
                      selected: negotiable,
                      onSelected: (_){
                        chipState((){
                          negotiable = true;
                        });
                      },
                      selectedColor: Colors.green,
                    ),
                    ChoiceChip(
                      label: Text('Non-negotiable'),
                      selected: !negotiable,
                      onSelected: (_){
                        chipState((){
                          negotiable = false;
                        });
                    },
                      selectedColor: Colors.green,
                    ),
                  ],
                );
              }
            ),
            SizedBox(height: 10,),
            for (int i = 0; i < n_images; i++)
              TextField(
                controller: imageControllers[i],
                decoration: InputDecoration(
                  labelText: 'Image Link',
                ),
              ),
            SizedBox(height: 30),
            MaterialButton(
              onPressed: () {
                setState(() {
                  n_images++;
                  imageControllers.add(TextEditingController());
                });
              },
              child: Text('Add Image'),
            ),
            SizedBox(height: 30),
            MaterialButton(
              onPressed: () async {
                final Firebase storage = Firebase();
                await storage.addProduct(
                    name: name.text,
                    description: description.text,
                    category: new_category.text.isNotEmpty ? new_category.text : category,
                    price: price.text,
                    details: details.text,
                    location: location.text,
                    images: imageControllers.map((image) => image.text).toList(),
                );
              },
              child: Text('Add'),
            ),
            // Image.network('https://firebasestorage.googleapis.com/v0/b/mnnit-a08f6.appspot.com/o/images%2F1718893634179.jpg?alt=media&token=b274855d-b645-4f4f-9592-a256f2bdc2ab'),
            TextButton(onPressed: () async {
              final storage = Firebase();
              await storage.removeFromHistory(productID: '0Ea7dW2kXI2UjM7YGB4j');
            }, child: Text('delete test')),
          ],
        ),
      ),
    );
  }
}
