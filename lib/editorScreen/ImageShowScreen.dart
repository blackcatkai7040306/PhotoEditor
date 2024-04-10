import 'dart:io';
import 'package:flutter/material.dart';

class shareScreen extends StatefulWidget {
  // ByteData byteData;
  var filePath = "";

  shareScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  State<shareScreen> createState() => _shareScreenState(imagePath: filePath);
}

class _shareScreenState extends State<shareScreen> {
  // ByteData byteDataOfImage;

  var imagePath = "";

  _shareScreenState({required this.imagePath});

  @override
  void initState() {
    setState(() {
      super.initState();
      print("ASdasdasdasda : ${imagePath}");
      // saveImage();
      // shareData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Share Screen"),
        ),
        body: Center(
          child: Container(
            child: Image.file(File(imagePath)),
          ),
        ),
      ),
    );
  }

  // void shareData() async{
  //   print("share share share");
  //   // await Share.shareFiles([imagePath], text: 'Image Shared');
  //   await FlutterShare.shareFile(
  //     title: 'Example share',
  //     text: 'Example share text',
  //     filePath:imagePath as String,
  //   );
  // }
}
