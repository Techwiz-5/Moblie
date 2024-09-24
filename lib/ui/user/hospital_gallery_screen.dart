import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class HospitalGalleryScreen extends StatefulWidget {
  const HospitalGalleryScreen({super.key, required this.hospital});
  final dynamic hospital;

  @override
  State<HospitalGalleryScreen> createState() => _HospitalGalleryScreenState();
}

class _HospitalGalleryScreenState extends State<HospitalGalleryScreen> {
  final CollectionReference myItems =
  FirebaseFirestore.instance.collection('ambulance');
  late PhotoViewController photoViewController;
  int idx = 0;
  List imageList = [];
  var isLoading = true;

  @override
  void initState() {
    super.initState();
    photoViewController = PhotoViewController();
    getBookedSlot();
  }

  getBookedSlot() async {
    QuerySnapshot querySnapshot = await myItems.where("hospital_id",isEqualTo: widget.hospital["id"]).get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    setState(() {
      imageList = allData;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    photoViewController.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      idx = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.hospital['name']}',
          style: const TextStyle(
          color: Colors.white,
            fontWeight: FontWeight.bold
        ),),
        backgroundColor: const Color(0xff223548),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) : PhotoViewGallery.builder(
        itemCount: imageList.length,
        pageController: PageController(initialPage: idx),
        onPageChanged: onPageChanged,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(
              imageList[index]['image'],
            ),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(
          color: Color(0xff475e75),
        ),
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      bottomSheet: Container(
        color: Color(0xff475e75),
          child: Text('Image ${idx+1}/${imageList.length}',style: TextStyle(color: Colors.white70),)),
    );
  }
}
