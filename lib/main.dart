import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:translator/translator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tradutor',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = "Tire uma foto do texto que deseja traduzir.";

  Future<PickedFile> pickImage() async =>
      await ImagePicker().getImage(source: ImageSource.camera);

  Future<String> readTextFromImage(PickedFile imageFile) async {
    FirebaseVisionImage ourImage =
        FirebaseVisionImage.fromFile(File(imageFile.path));
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await recognizeText.processImage(ourImage);
    return visionText.text;
  }

  Future<String> translate(String text) async {
    GoogleTranslator translator = GoogleTranslator();
    Translation translation = await translator.translate(text, to: 'pt');
    return translation.text;
  }

  void translateTextImage() async {
    var pickedFile = await pickImage();
    var originalText = await readTextFromImage(pickedFile);
    var translatedText = await translate(originalText);

    setState(() {
      text = translatedText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(text),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.translate), onPressed: translateTextImage),
    );
  }
}
