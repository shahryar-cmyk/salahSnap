// ✅ Same Imports – keep them
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

  // Display order
  final List<Map<String, String>> _prayerOrder = [
    {'key': 'Fajr', 'name': 'Fajr'},
    {'key': 'Dhuhr', 'name': 'Dhuhr'},
    {'key': 'Asr', 'name': 'Asr'},
    {'key': 'Maghrib', 'name': 'Maghrib'},
    {'key': 'Isha', 'name': 'Isha'},
  ];

  /// ⬇️ Show camera/gallery selector
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

  Future<File> applySharpness(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return imageFile;

    // Sharpening kernel (standard 3x3 sharpen matrix)
    final sharpenKernel = [
      0,
      -1,
      0,
      -1,
      5,
      -1,
      0,
      -1,
      0,
    ];

    // Apply convolution filter
    img.Image sharpened =
        img.convolution(original, div: 1, offset: 0, filter: []);

    // Save image
    final sharpPath = imageFile.path
        .replaceFirst('.jpg', '_sharp.jpg')
        .replaceFirst('.png', '_sharp.png');
    final newFile = File(sharpPath);
    await newFile.writeAsBytes(img.encodeJpg(sharpened));
    return newFile;
  }

  /// ⬇️ Pick image & perform full OCR + parsing //
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Step 1: Convert to grayscale
      File originalFile = File(pickedFile.path);
      File grayImage = await convertToGrayscale(originalFile);

      // Step 2: OCR on grayscale image
      final inputImage = InputImage.fromFilePath(grayImage.path);
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      setState(() {
        _image = grayImage;
        _text = recognizedText.text;
        _prayerTimes.clear(); // Clear previous data
        _parsePrayerTimes(_text); // Parse the extracted text
      });

      textRecognizer.close();
    }
  }

  Future<File> convertToGrayscale(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return imageFile;

    // Step 1: Convert to grayscale
    img.Image grayscale = img.grayscale(original);

    // Step 2: Increase contrast
    grayscale = img.adjustColor(grayscale, contrast: 1.0);

    // ✅ Step 3: Apply sharpness using convolution filter
    final sharpenKernel = [
      0,
      -1,
      0,
      -1,
      5,
      -1,
      0,
      -1,
      0,
    ];
    grayscale = img.convolution(grayscale, filter: sharpenKernel, div: 1);

    // Step 4: Save the processed image
    final grayPath = imageFile.path
        .replaceFirst('.jpg', '_gray.jpg')
        .replaceFirst('.png', '_gray.png');
    final newFile = File(grayPath);
    await newFile.writeAsBytes(img.encodeJpg(grayscale));
    return newFile;
  }

  /// ⬇️ Convert Arabic digits to English
  String convertArabicToEnglishDigits(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }
    return input;
  }

  /// ⬇️ Parse times & labels from OCR text
  void _parsePrayerTimes(String text) {
    final lines = text.split('\n');
    final times = <String>[];

    // Arabic prayer names mapped to English
    final Map<String, String> knownLabels = {
      "الفجر": "Fajr",
      "الظهر": "Dhuhr",
      "العصر": "Asr",
      "المغرب": "Maghrib",
      "العشاء": "Isha",
    };

    // Time format: HH:MM or H:MM using colon or Arabic decimal
    final timeRegex = RegExp(r'(\d{1,2})[:٫](\d{2})');

    // Step 1: Collect raw times
    for (final line in lines) {
      final cleanLine = convertArabicToEnglishDigits(line);
      final match = timeRegex.firstMatch(cleanLine);
      if (match != null) {
        final hour = match.group(1);
        final minute = match.group(2);
        times.add('$hour:$minute');
      }
    }

    // Step 2: Map times with labels if found
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

    // Step 3: Fallback – Assign in order
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
                  Center(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _text = _text.replaceAll(RegExp(r'[a-zA-Z]'), '');
                            });
                          },
                          child: const Text("Remove alphabets"),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text("Remove Background"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_image != null) {
                              File sharpImage = await applySharpness(_image!);
                              setState(() {
                                _image = sharpImage;
                              });
                            }
                          },
                          child: const Text("Remove Sharpness"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _text = _text.replaceAll(RegExp(r'[a-zA-Z]'), '');
                            });
                          },
                          child: const Text("Remove Contrast"),
                        ),
                        ElevatedButton(
                          onPressed: () async {},
                          child: const Text("Remove Grayscale"),
                        ),
                      ],
                    ),
                  ),
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
                                      style: const TextStyle(fontSize: 18),
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
