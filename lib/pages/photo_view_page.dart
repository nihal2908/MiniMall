import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
// import 'package:image_downloader/image_downloader.dart';

class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  ImageGallery({required this.imageUrls, this.initialIndex = 0});

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Product Images"),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              // await _downloadImage(widget.imageUrls[currentIndex]);
            },
          )
        ],
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.imageUrls[index]),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: widget.initialIndex),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  // Future<void> _downloadImage(String url) async {
  //   try {
  //     // Download the image and save it to the gallery
  //     var imageId = await ImageDownloader.downloadImage(url);
  //     if (imageId == null) {
  //       return;
  //     }
  //     // Display a success message
  //     print('Image downloaded successfully');
  //   } catch (error) {
  //     print('Error downloading image: $error');
  //   }
  // }
}
