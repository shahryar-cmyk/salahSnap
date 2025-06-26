import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class ImageTOText extends StatefulWidget {
  const ImageTOText({Key? key}) : super(key: key);

  @override
  State<ImageTOText> createState() => _ImageTOTextState();
}

class _ImageTOTextState extends State<ImageTOText> {
  File? _image;
  String _text = "";
  final Map<String, String> _prayerTimes = {};

  // Define the order of prayers to display
  final List<Map<String, String>> _prayerOrder = [
    {'key': 'Fajr', 'name': 'Fajr'},
    {'key': 'Dhuhr', 'name': 'Dhuhr'},
    {'key': 'Asr', 'name': 'Asr'},
    {'key': 'Maghrib', 'name': 'Maghrib'},
    {'key': 'Isha', 'name': 'Isha'},
  ];

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File grayImage = await convertToGrayscale(File(pickedFile.path));

      final inputImage = InputImage.fromFilePath(grayImage.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      setState(() {
        _image = grayImage;
        _text = recognizedText.text;
        _prayerTimes.clear();
        _parsePrayerTimes(_text);
      });

      textRecognizer.close();
    }
  }

  Future<File> convertToGrayscale(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return imageFile;

    img.Image grayscale = img.grayscale(original);
    final grayPath = imageFile.path
        .replaceFirst('.jpg', '_gray.jpg')
        .replaceFirst('.png', '_gray.png');
    final newFile = File(grayPath);
    await newFile.writeAsBytes(img.encodeJpg(grayscale));
    return newFile;
  }

  String convertArabicToEnglishDigits(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    return input;
  }

  void _parsePrayerTimes(String text) {
    final lines = text.split('\n');
    final times = <String>[];

    final Map<String, String> knownLabels = {
      "الفجر": "Fajr",
      "الظهر": "Dhuhr",
      "العصر": "Asr",
      "المغرب": "Maghrib",
      "العشاء": "Isha",
    };

    final timeRegex = RegExp(r'(\d{1,2})[:٫](\d{2})');

    // First pass: Extract all times in order
    for (final line in lines) {
      final cleanLine = convertArabicToEnglishDigits(line);
      final match = timeRegex.firstMatch(cleanLine);
      if (match != null) {
        final hour = match.group(1);
        final minute = match.group(2);
        times.add('$hour:$minute');
      }
    }

    // Second pass: Try to match with labels
    bool foundLabeledTimes = false;
    for (final line in lines) {
      final cleanLine = convertArabicToEnglishDigits(line);
      for (var label in knownLabels.keys) {
        if (cleanLine.contains(label)) {
          final match = timeRegex.firstMatch(cleanLine);
          if (match != null) {
            final hour = match.group(1);
            final minute = match.group(2);
            _prayerTimes[knownLabels[label]!] = '$hour:$minute';
            foundLabeledTimes = true;
          }
        }
      }
    }

    // If no labeled times found, assign in order (first time to Fajr, second to Dhuhr, etc.)
    if (!foundLabeledTimes && times.isNotEmpty) {
      for (int i = 0; i < times.length && i < _prayerOrder.length; i++) {
        _prayerTimes[_prayerOrder[i]['key']!] = times[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prayer Time Extractor"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_image != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(_image!),
              ),
            Center(
              child: ElevatedButton(
                onPressed: _showImageSourceDialog,
                child: const Text("Pick Image & Extract Prayer Times"),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_text.isNotEmpty) ...[
                    const Text(
                      "Raw Extracted Text:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_text),
                    const SizedBox(height: 20),
                  ],
                  if (_prayerTimes.isNotEmpty) ...[
                    const Text(
                      "Prayer Times:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Display prayer times in order
                    Column(
                      children: _prayerOrder.map((prayer) {
                        final time = _prayerTimes[prayer['key']];
                        return time != null
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                child: Row(
                                  children: [
                                    Text(
                                      "${prayer['name']}: ",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      time,
                                      style: const TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink();
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
