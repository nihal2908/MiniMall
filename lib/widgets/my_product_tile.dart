import 'package:flutter/material.dart';
import 'package:mnnit/customFunctions/navigator_functions.dart';
import 'package:mnnit/firebase/firebase_storage.dart';
import 'package:mnnit/models/product.dart';
import 'package:mnnit/pages/edit_product_details_page.dart';
import 'package:mnnit/pages/my_product_detail_page.dart';

class MyProductTile extends StatelessWidget {
  final Product product;
  final void Function(void Function()) reload;
  const MyProductTile({required this.product, required this.reload});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(product.images[0]),
        title: Text(product.name),
        subtitle: Text('\₹${product.price}'),
        contentPadding: EdgeInsets.only(left: 9),
        trailing: IconButton(
          onPressed: (){
            showMyProductOprions(context);
          },
          icon: Icon(Icons.more_vert),
        ),
        onTap: () {
          push(context: context, page: MyProductDetailPage(product: product,));
        },
      ),
    );
  }

  void showMyProductOprions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context)=>
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15,),
                Text(product.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                ListTile(
                  title: Text('Edit Product Details'),
                  leading: Icon(Icons.edit_note),
                  onTap: (){
                    push(context: context, page: EditProductDetailsPage(product: product));
                  },
                ),
                ListTile(
                  title: Text('Hide Product'),
                  leading: Icon(Icons.hide_source),
                  onTap: (){
                    showHideProductDialog(context);
                  },
                ),
                ListTile(
                  title: Text('Delete Product'),
                  leading: Icon(Icons.delete),
                  onTap: (){
                    showDeleteProductDialog(context);
                  },
                ),
                const SizedBox(height: 10,),
              ],
            ),
          ),
    );
  }

  void showDeleteProductDialog(BuildContext context) async {
    showDialog(context: context, builder: (context){
      final Firebase _firebase = Firebase();
      return AlertDialog(
        title: Text('Delete Product?'),
        content: Text('Do you want to permanently delete the product from the store?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firebase.deleteProduct(productID: product.id);
              pop(context: context);
              pop(context: context);
              reload((){});
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    });
  }

  void showHideProductDialog(BuildContext context) async {
    showDialog(context: context, builder: (context){
      final Firebase _firebase = Firebase();
      return AlertDialog(
        title: Text('Hide Product?'),
        content: Text('Do you want to temporary hide product from the store?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.green)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firebase.hideProduct(productID: product.id);
              pop(context: context);
              reload((){});
            },
            child: Text('Hide', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    });
  }
}