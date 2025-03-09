import 'dart:io';

import 'package:aiimagetotext/claude_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  File? _image;
  String? _description;
  bool _isLoading = false;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
          source: source, maxHeight: 1080, maxWidth: 1920, imageQuality: 85);

      // if the image has been choosen then lets start the analysis
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _analyzeImage();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final description = await ClaudeService().analyzeImage(_image!);

      setState(() {
        _description = description;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI VISION APP'),
      ),
      body: Column(
        children: [
          // display image 
          Container(
            height: 300,
            color: Colors.grey,
            child: _image!=null ? Image.file(_image!):Center(child: Text("choose image ...")),
            
            ),
          const  SizedBox(height: 25,),
          // buttons 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // button -> take photos
              ElevatedButton(onPressed: ()=>_pickImage(ImageSource.camera),
              child: const Text("Take photo")),

              // button -> pick photo from the gallery
              ElevatedButton(onPressed: ()=>_pickImage(ImageSource.gallery),
              child: const Text("pick from gallery "))

            ],
          ),

          // description
          const SizedBox(),

          if(_isLoading)
            const Center(child: CircularProgressIndicator(),)
          else if(_description != null)
            Text(_description!)
        ],
      ),
    );
  }
}
