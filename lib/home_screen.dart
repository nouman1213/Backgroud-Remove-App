import 'dart:io';

import 'package:before_after_image_slider_nullsafty/before_after_image_slider_nullsafty.dart';
import 'package:bg_remove/services/api_services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ScreenshotController screenshotController = ScreenshotController();
  var loaded = false;
  var removeBg = false;
  var isLoading = false;

  Uint8List? image;
  String imgPath = '';

  pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (img != null) {
      imgPath = img.path;
      loaded = true;
      setState(() {});
    } else {}
  }

  dowmloadImage() async {
    var foldername = 'bg_remove';
    var filename = "${DateTime.now().millisecondsSinceEpoch}.png";
    var prem = await Permission.storage.request();
    if (prem.isGranted) {
      final directory = Directory("storage/emulated/0/$foldername");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      await screenshotController.captureAndSave(directory.path,
          delay: const Duration(milliseconds: 100),
          fileName: filename,
          pixelRatio: 1.0);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Image Downloaded")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Background'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                // Add your on tap code here
                pickImage();
              },
              child: removeBg
                  ? BeforeAfter(
                      beforeImage: Image.file(File(imgPath)),
                      afterImage: Screenshot(
                          controller: screenshotController,
                          child: Image.memory(image!)),
                    )
                  : loaded
                      ? GestureDetector(
                          onTap: () {
                            pickImage();
                          },
                          child: Image.file(File(imgPath)))
                      : Container(
                          width: double.infinity,
                          height: 50.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 2.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Select Image',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                        ),
            ),
            const SizedBox(height: 20),
            removeBg
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = false;
                              removeBg = false;
                            });
                            pickImage();
                          },
                          child: const Text('Re-Select Image')),
                      ElevatedButton(
                          onPressed: () {
                            dowmloadImage();
                          },
                          child: const Text('Download Image')),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: loaded
                ? () async {
                    setState(() {
                      isLoading = true;
                    });
                    image = await ApiServices.removeBg(imgPath);
                    if (image != null) {
                      removeBg = true;
                      isLoading = false;
                      setState(() {});
                    }
                  }
                : null,
            child: isLoading
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  )
                : const Text(
                    'Remove Background',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          )),
    );
  }
}
