import 'dart:io';

import 'package:barcode_scanning/components/result_item.dart';
import 'package:barcode_scanning/pages/live_page.dart';
import 'package:barcode_scanning/utils/constants.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  HomePage({Key? key, required this.cameras}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final BarcodeScanner barcodeScanner;
  late ImagePicker imagePicker;
  late Future<File> imageFile;
  File? _image;
  String? result = '';

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
    barcodeScanner = GoogleMlKit.vision.barcodeScanner();
  }

  doBarcodeScanning() async {
    final inputImage = InputImage.fromFile(_image!);

    final List<Barcode> barcodes =
        await barcodeScanner.processImage(inputImage);
    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      final Rect? boundingBox = barcode.value.boundingBox;
      final String? displayValue = barcode.value.displayValue;
      final String? rawValue = barcode.value.rawValue;

      switch (type) {
        case BarcodeType.wifi:
          BarcodeWifi barcodeWifi = barcode.value as BarcodeWifi;
          setState(() {
            result = barcodeWifi.password;
          });
          break;
        case BarcodeType.url:
          BarcodeUrl barcodeUrl = barcode.value as BarcodeUrl;
          setState(() {
            result = barcodeUrl.rawValue;
          });
          break;
        case BarcodeType.email:
          BarcodeEmail barcodeEmail = barcode.value as BarcodeEmail;
          setState(() {
            result = barcodeEmail.displayValue;
          });
          break;
        case BarcodeType.phone:
          BarcodePhone barcodePhone = barcode.value as BarcodePhone;
          setState(() {
            result = barcodePhone.rawValue;
          });
          break;
        case BarcodeType.calendarEvent:
          BarcodeCalenderEvent barcodeCalenderEvent =
              barcode.value as BarcodeCalenderEvent;
          setState(() {
            result =
                '${barcodeCalenderEvent.displayValue} - ${barcodeCalenderEvent.startRawValue}';
          });
          break;
      }
    }
  }

  _imgFromCamera() async {
    PickedFile? image = await imagePicker.getImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    setState(() {
      _image = File(image!.path);
      if (_image != null) {
        doBarcodeScanning();
      }
    });
  }

  _imgFromGallery() async {
    PickedFile? image = await imagePicker.getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    setState(() {
      _image = File(image!.path);
      if (_image != null) {
        doBarcodeScanning();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Constants.backgroundColor,
        floatingActionButton: FloatingActionButton(
          onPressed: showCameraOptionsDialog,
          backgroundColor: Constants.accentColor,
          child: Icon(Icons.camera_alt),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 15),
                      child: _image != null
                          ? Image.file(
                              _image!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.fill,
                            )
                          : Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Constants.dialogColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Constants.backgroundColor,
                              ),
                            ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: ResultItem(
                      text: result!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showCameraOptionsDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Galeria or Câmera?",
          style: TextStyle(color: Constants.textColor),
        ),
        backgroundColor: Constants.dialogColor,
        content: Text(
          "Você quer escolher uma imagem da sua galeria ou tirar uma foto?",
          style: TextStyle(color: Constants.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LivePage(
                    camera: widget.cameras[0],
                  ),
                ),
              );
            },
            child: Text(
              "Live",
              style: TextStyle(color: Colors.blue[300]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _imgFromCamera();
            },
            child: Text(
              "Câmera",
              style: TextStyle(color: Colors.blue[300]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _imgFromGallery();
            },
            child: Text(
              "Galeria",
              style: TextStyle(color: Colors.blue[300]),
            ),
          ),
        ],
      ),
    );
  }
}
