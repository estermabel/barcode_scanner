import 'package:barcode_scanning/components/result_item.dart';
import 'package:barcode_scanning/utils/constants.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class LivePage extends StatefulWidget {
  final CameraDescription camera;
  const LivePage({Key? key, required this.camera}) : super(key: key);

  @override
  _LivePageState createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  late CameraController controller;
  late CameraImage _image;
  late BarcodeScanner scanner;
  bool isBusy = false;
  String? result = '';

  @override
  void initState() {
    super.initState();
    scanner = GoogleMlKit.vision.barcodeScanner();
    initializeCamera();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  initializeCamera() async {
    controller = CameraController(widget.camera, ResolutionPreset.max);
    await controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) {
        if (!isBusy) {
          isBusy = true;
          _image = image;
          doBarcodeScanning();
        }
      });
    });
    setState(() {});
  }

  InputImage getInputImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final InputImageRotation imageRotation =
        InputImageRotationMethods.fromRawValue(
                widget.camera.sensorOrientation) ??
            InputImageRotation.Rotation_0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatMethods.fromRawValue(image.format.raw) ??
            InputImageFormat.NV21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    return inputImage;
  }

  doBarcodeScanning() async {
    var inputImage = getInputImage(_image);
    final List<Barcode> barcodes = await scanner.processImage(inputImage);
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
    isBusy = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.dialogColor,
        title: Text('Live'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 50),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Container(
                      height: 200,
                      width: 200,
                      child: !controller.value.isInitialized
                          ? Container(
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
                            )
                          : AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: CameraPreview(controller),
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
    );
  }
}
