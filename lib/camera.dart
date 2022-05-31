import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:pytorch_mobile/model.dart';
import 'package:pytorch_mobile/pytorch_mobile.dart';

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
  super.key,
  required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //appBar: AppBar(title: const Text('Take a picture')),
        // You must wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner until the
        // controller has finished initializing.
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return CameraPreview(_controller);
            } else {
              // Otherwise, display a loading indicator.
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          // Provide an onPressed callback.
          onPressed: () async {
            // Take the Picture in a try / catch block. If anything goes wrong,
            // catch the error.
            try {
              // Ensure that the camera is initialized.
              await _initializeControllerFuture;

              // Attempt to take a picture and get the file `image`
              // where it was saved.
              final image = await _controller.takePicture();

              // If the picture was taken, display it on a new screen.
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                    // Pass the automatically generated path to
                    // the DisplayPictureScreen widget.
                    imagePath: image.path,
                  ),
                ),
              );
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  late String imagePath;

  DisplayPictureScreen({super.key, required this.imagePath}) {
    imagePath = this.imagePath;
  }

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late Model imageModel;
  late String prediction = "Please Wait as we process your image :)";
  final List<double> mean = [0.485, 0.456, 0.406];
  final List<double> std = [0.229, 0.224, 0.225];

  var body = SafeArea(
    child: Scaffold(
        body: Prediction(prediction: "Please Wait as we process your image :)", img: "",)
    ),
  );

  _DisplayPictureScreenState() {
    init();
  }

  Future<void> init() async {
    imageModel = await PyTorchMobile.loadModel('assets/models/traced_resnet_model.pt');
    prediction = await imageModel.getImagePrediction(File(widget.imagePath), 224, 224, "assets/labels/labels.csv", mean: mean, std: std);
    print(prediction);

    setState(() {
      body = SafeArea(
        child: Scaffold(
            body: Prediction(prediction: prediction, img: widget.imagePath)
        ),
      );
    });
  }

//Image.file(File(imagePath))
  @override
  Widget build(BuildContext context) {
    return body;
  }
}

class Prediction extends StatelessWidget {
  var prediction;
  var img;
  var desc;

  Prediction({Key? key, required this.prediction, required this.img}) : super(key: key) {
    prediction = prediction;
    if (prediction == "nevus") {
      img = Image.file(File(img));
      desc = const Text(
        "A nevus is a benign (not cancer) growth on the skin that is formed by a cluster of melanocytes (cells that make a substance called melanin, which gives color to skin and eyes). A nevus is usually dark and may be raised from the skin. Also called mole.",
        style: TextStyle(
          fontSize: 18,
          color: Colors.deepPurpleAccent,
        ),
        textAlign: TextAlign.center,
      );
    } else if (prediction == "melanoma") {
      img = Image.file(File(img));
      desc = const Text(
        "A melanoma is a form of cancer that begins in melanocytes (cells that make the pigment melanin). It may begin in a mole (skin melanoma), but can also begin in other pigmented tissues, such as in the eye or in the intestines.\nWe recommend approaching a dermatologist",
        style: TextStyle(
          fontSize: 18,
          color: Colors.deepPurpleAccent,
        ),
        textAlign: TextAlign.center,
      );
    } else if (prediction == "seborrheic keratosis") {
      img = Image.file(File(img));
      desc = const Text(
        "Seborrheic keratosis is a condition that causes wart-like growths on the skin. The growths are noncancerous (benign).",
        style: TextStyle(
          fontSize: 18,
          color: Colors.deepPurpleAccent,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      img = Container();
      desc = Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              const Padding(padding: EdgeInsets.all(16)),
              img,
              const Padding(padding: EdgeInsets.all(16)),
              const Divider(
                height: 8,
                thickness: 1,
                indent: 8,
                endIndent: 8,
                color: Colors.grey,
              ),
              const Padding(padding: EdgeInsets.all(16)),
              Text(
                "We predict your image to be: " + prediction,
                style: const TextStyle(
                  fontSize: 33,
                  color: Colors.deepPurpleAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.all(8)),
              desc,
            ],
          ),
        ),
      ),
    );
  }
}

class PleaseWait extends StatelessWidget {
  const PleaseWait({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Please wait as we process your image :)",
          style: TextStyle(
            fontSize: 33,
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}



