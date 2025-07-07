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
  bool _isSharpnessApplied = false;
  bool _isContrastApplied = false;
  bool _isGrayscaleApplied = false;

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

  Future<File> applySharpness(File imageFile, bool apply) async {
    // Directly accessing the image 1 from google_mlkit_text_recognition to add sharpness
    // Correct
    // Fajr InCorrect [4:15] to [4:5 ill]
    // Dhohr InCorrect  [1:00] to [:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - InCorrect  [7:16] to [7:75]
    // Isha - correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 2 from google_mlkit_text_recognition to add sharpness
    // Correct
    // Fajr InCorrect [4:15] to [4:5 ill]
    // Dhohr InCorrect  [1:00] to [:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - InCorrect  [7:16] to [7:75]
    // Isha - correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 3 from google_mlkit_text_recognition to add sharpness
    // Correct
    // Fajr Correct [4:15] to [4:15 ill]
    // Dhohr missing
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - missing
    // Isha - correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 4 from google_mlkit_text_recognition to add sharpness
    // Correct
    // Fajr InCorrect [4:15] to [4:5 ill]
    // Dhohr Correct  [1:00] to [1:00]
    // Asr InCorrect [5:15] to [5:5 a]
    // Magrib - InCorrect  [7:16] to [:76]
    // Isha - correct [9:00] to [9:00]
    // Juma - incorrect [1:00] to [:00]

    // Directly accessing the image 5 from google_mlkit_text_recognition to add sharpness
    // Correct
    // Fajr Correct [4:15] to [4:15 ]
    // Dhohr InCorrect  [1:00] to [H:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - Correct  [7:16] to [7:16]
    // Isha - correct [9:00] to [9:00]
    // Juma - correct [1:00] to [1:00]

    // Directly accessing the image 6 from google_mlkit_text_recognition to add sharpness
    // Correct
    // Fajr Correct [4:15] to [4:15 ]
    // Dhohr missing
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - Correct  [7:16] to [7:16]
    // Isha - correct [9:00] to [9:00]
    // Juma - Incorrect [1:00] to [1:]

    // Directly accessing the image 7 from google_mlkit_text_recognition to add sharpness
    // Correct
    // Fajr Correct [4:15] to [4:15 ]
    // Dhohr InCorrect  [1:00] to [I:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - InCorrect  [7:16] to [:16]
    // Isha - correct [9:00] to [9:00]
    // Juma - missing

    // Directly accessing the image 8 from google_mlkit_text_recognition to add sharpness
    // Correct
    // Fajr inCorrect [4:15] to [4:I5 ]
    // Dhohr InCorrect  [1:00] to [BI:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - Correct  [7:16] to [7:16]
    // Isha - missing
    // Juma - missing

    // Directly accessing the image 9 from google_mlkit_text_recognition to add sharpness
    // Correct
    // Fajr inCorrect [4:15] to [4:I5 ]
    // Dhohr InCorrect  [1:00] to [BA:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - Correct  [7:16] to [7:16]
    // Isha - correct [9:00] to [9:00]
    // Juma - missing

    // Directly accessing the image 10 from google_mlkit_text_recognition to add sharpness
    // Correct
    // Fajr inCorrect [4:15] to [4:I5 ]
    // Dhohr missing
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - missing
    // Isha - missing
    // Juma - missing
    final bytes = await imageFile.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return imageFile;

    if (apply) {
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
      original =
          img.convolution(original, div: 1, offset: 0, filter: sharpenKernel);
    }

    // Save image
    final sharpPath = imageFile.path
        .replaceFirst('.jpg', '_sharp.jpg')
        .replaceFirst('.png', '_sharp.png');
    final newFile = File(sharpPath);
    await newFile.writeAsBytes(img.encodeJpg(original));
    return newFile;
  }

  Future<File> applyContrast(File imageFile, bool apply) async {
    // Directly accessing the image 1 from google_mlkit_text_recognition to add contrast
    // Correct
    // Fajr Correct [4:15] to [4:15 ill]
    // Dhohr InCorrect  [1:00] to [:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - InCorrect [7:16] to [7:N6]
    // Isha - missing
    // Juma - Missing

    // Directly accessing the image 2 from google_mlkit_text_recognition to add contrast
    // Correct
    // Fajr Correct [4:15] to [4:15 ill]
    // Dhohr InCorrect  [1:00] to [HI:00]
    // Asr Correct [5:15] to [5:15 al]
    // Magrib - missing
    // Isha - correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 3 from google_mlkit_text_recognition to add contrast
    // Correct
    // Fajr missing
    // Dhohr Correct  [1:00] to [1:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - InCorrect [7:16] to [7:I5]
    // Isha - correct [9:00] to [9:00]
    // Juma - correct [1:00] to [1:00]

    // Directly accessing the image 4 from google_mlkit_text_recognition to add contrast
    // Correct
    // Fajr Correct [4:15] to [4:15 ill]
    // Dhohr InCorrect  [1:00] to [I:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - missing
    // Isha - correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 5 from google_mlkit_text_recognition to add contrast
    // Correct
    // Fajr Correct [4:15] to [4:15 ill]
    // Dhohr InCorrect  [1:00] to [:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - InCorrect [7:16] to [7:15]
    // Isha - correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 6 from google_mlkit_text_recognition to add contrast
    // Correct
    // Fajr Correct [4:15] to [4:15 ill]
    // Dhohr missing
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - InCorrect [7:16] to [7:N6]
    // Isha - correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 7 from google_mlkit_text_recognition to add contrast
    // Correct
    // Fajr Correct [4:15] to [4:15 ill]
    // Dhohr Correct  [1:00] to [1:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - InCorrect [7:16] to [7:N6]
    // Isha - correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 8 from google_mlkit_text_recognition to add contrast
    // Correct
    // Fajr Correct [4:15] to [4:15 ill]
    // Dhohr missing
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - missing
    // Isha - correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 9 from google_mlkit_text_recognition to add contrast
    // Correct
    // Fajr Correct [4:15] to [4:15 ill]
    // Dhohr missing
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - InCorrect [7:16] to [7:N6]
    // Isha - missing
    // Juma - Missing

    // Directly accessing the image 10 from google_mlkit_text_recognition to add contrast
    // Correct
    // Fajr missing
    // Dhohr InCorrect  [1:00] to [:00]
    // Asr Correct [5:15] to [5:15 a]
    // Magrib - missing
    // Isha - correct [9:00] to [9:00]
    // Juma - Missing
    final bytes = await imageFile.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return imageFile;

    if (apply) {
      original = img.adjustColor(original, contrast: 0.5); // High contrast
    } else {
      original = img.adjustColor(original, contrast: 0.5); // Normal contrast
    }

    final contrastPath = imageFile.path
        .replaceFirst('.jpg', '_contrast.jpg')
        .replaceFirst('.png', '_contrast.png');
    final newFile = File(contrastPath);
    await newFile.writeAsBytes(img.encodeJpg(original));
    return newFile;
  }

  Future<File> applyGrayscale(File imageFile, bool apply) async {
    // Directly accessing the image 1 from google_mlkit_text_recognition to convert Grayscale
    // Correct
    // Fajr Correct [4:15] to [4:15]
    // Dhohr Correct  [1:00] to [1:00]
    // Asr Correct [5:15] to [5:15]
    // Magrib - Correct [7:16] to [7:16]
    // Isha - Correct [9:00] to [9:00]
    // Juma - Missing

// Directly accessing the image 2 from google_mlkit_text_recognition to convert Grayscale
    // Correct
    // Fajr Missing
    // Dhohr Correct  [1:00] to [1:00]
    // Asr Correct [5:15] to [5:15]
    // Magrib - Missing
    // Isha - Missing
    // Juma - Correct [1:00] to [1:00]

    // Directly accessing the image 3 from google_mlkit_text_recognition to convert Grayscale
    // Correct
    // Fajr Correct [4:15] to [4:15]
    // Dhohr InCorrect  [1:00] to [:00]
    // Asr Correct [5:15] to [5:15]
    // Magrib - Correct [7:16] to [7:16]
    // Isha - Correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 4 from google_mlkit_text_recognition to convert Grayscale
    // Correct
    // Fajr Correct [4:15] to [4:15]
    // Dhohr InCorrect  [1:00] to [I:00]
    // Asr Correct [5:15] to [5:15]
    // Magrib - InCorrect [7:16] to [1:16]
    // Isha - Correct [9:00] to [9:00]
    // Juma - Incorrect [1:00] to [I:00]

    // Directly accessing the image 5 from google_mlkit_text_recognition to convert Grayscale
    // Correct
    // Fajr Correct [4:15] to [4:15]
    // Dhohr Correct  [1:00] to [1:00]
    // Asr Correct [5:15] to [5:15]
    // Magrib - Correct [7:16] to [7:16]
    // Isha - Correct [9:00] to [9:00]
    // Juma - correct [1:00] to [1:00]

    // Directly accessing the image 6 from google_mlkit_text_recognition to convert Grayscale
    // Correct
    // Fajr Correct [4:15] to [4:15]
    // Dhohr InCorrect  [1:00] to [H:00]
    // Asr Correct [5:15] to [5:15]
    // Magrib - missing
    // Isha - Correct [9:00] to [9:00]
    // Juma - Incorrect [1:00] to [I:00]

    // Directly accessing the image 7 from google_mlkit_text_recognition to convert Grayscale
    // Correct
    // Fajr Correct [4:15] to [4:15]
    // Dhohr Missing
    // Asr Correct [5:15] to [5:15]
    // Magrib - Correct [7:16] to [7:16]
    // Isha - Correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 8 from google_mlkit_text_recognition to convert Grayscale
    // Correct
    // Fajr Correct [4:15] to [4:15]
    // Dhohr missing
    // Asr Correct [5:15] to [5:15]
    // Magrib - Correct [7:16] to [7:16]
    // Isha - missing
    // Juma - Missing

    // Directly accessing the image 9 from google_mlkit_text_recognition to convert Grayscale
    // Correct
    // Fajr InCorrect [4:15] to [4:I5I]
    // Dhohr Correct  [1:00] to [1:00]
    // Asr InCorrect [5:15] to [5:I5 al]
    // Magrib - Correct [7:16] to [7:16 il]
    // Isha - missing
    // Juma - Missing

    // Directly accessing the image 10 from google_mlkit_text_recognition to convert Grayscale
    // Correct
    // Fajr Correct [4:15] to [4:15]
    // Dhohr InCorrect  [1:00] to [:00]
    // Asr InCorrect [5:15] to [5:I5]
    // Magrib - Correct [7:16] to [7:16]
    // Isha - missing
    // Juma - Missing
    final bytes = await imageFile.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return imageFile;

    if (apply) {
      original = img.grayscale(original);
    }

    final grayPath = imageFile.path
        .replaceFirst('.jpg', '_gray.jpg')
        .replaceFirst('.png', '_gray.png');
    final newFile = File(grayPath);
    await newFile.writeAsBytes(img.encodeJpg(original));
    return newFile;
  }

  /// ⬇️ Pick image & perform full OCR + parsing //
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Reset all effects when new image is picked
      _isSharpnessApplied = false;
      _isContrastApplied = false;
      _isGrayscaleApplied = false;

      File originalFile = File(pickedFile.path);
      setState(() {
        _image = originalFile;
      });

      // Perform initial OCR
      await performOCR(originalFile);
    }
  }

  Future<void> performOCR(File imageFile) async {
    // Directly accessing the image from google_mlkit_text_recognition
    // Correct
    // Fajr
    // Dhohr
    // Asr
    // Magrib - Incorrect
    // Isha - Correct
    // Juma - Missing

// Directly accessing the image 2  from google_mlkit_text_recognition
    // Correct
    // Fajr [4:15 ] to 4:I5 ill
    // Dhohr [1:00 ] to B:00
    // Asr [5:15 ] to 5:15 yal
    // Magrib - []
    // Isha - Correct [9:00] to [9:00]
    // Juma - Incorrect [1:00] to [:00]

    // Directly accessing the image 3  from google_mlkit_text_recognition
    // Correct
    // Fajr Correct [4:15 ] to 4:I5 ill
    // Dhohr Missing
    // Asr [5:15 ] to 5:15 al
    // Magrib - Correct [7:16] to [7:16]
    // Isha - Correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 4  from google_mlkit_text_recognition
    // Correct
    // Fajr Correct [4:15 ] to 4:15 ill
    // Dhohr Incorrect [1:00 ] to [H:00]
    // Asr [5:15 ] to 5:15 al
    // Magrib - Correct [7:16] to [7:16]
    // Isha - Correct [9:00] to [9:00]
    // Juma - Correct [1:00] to [1:00]

    // Directly accessing the image 5  from google_mlkit_text_recognition
    // Correct
    // Fajr Correct [4:15 ] to 4:I5 ill
    // Dhohr Incorrect [1:00 ] to [I:00]
    // Asr Correct[5:15 ] to 5:I5 al
    // Magrib - Correct [7:16] to [1:16]
    // Isha - Correct [9:00] to [9:00]
    // Juma - Correct [1:00] to [i:00]

    // Directly accessing the image 6  from google_mlkit_text_recognition
    // Correct
    // Fajr Correct [4:15 ] to 4:I5 ill
    // Dhohr correct [1:00 ] to [1:00]
    // Asr Correct[5:15 ] to 5:I5 al
    // Magrib - Correct [7:16] to [7:15]
    // Isha - Correct [9:00] to [9:00]
    // Juma - Correct [1:00] to [1:00]

    // Directly accessing the image 7  from google_mlkit_text_recognition
    // Correct
    // Fajr Correct [4:15 ] to 4:15 ill
    // Dhohr INcorrect [1:00 ] to [h:00]
    // Asr Correct[5:15 ] to 5:15 al
    // Magrib - Missing
    // Isha - Correct [9:00] to [9:00]
    // Juma - inCorrect [1:00] to [:00]

    // Directly accessing the image 8  from google_mlkit_text_recognition
    // Correct
    // Fajr Correct [4:15 ] to 4:15 ill
    // Dhohr correct [1:00 ] to [1:00]
    // Asr Correct[5:15 ] to 5:15 al
    // Magrib - correct [7:16] to [7:16]
    // Isha - Correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 9  from google_mlkit_text_recognition
    // Correct
    // Fajr Correct [4:15 ] to 4:15 ill
    // Dhohr correct Missing
    // Asr Correct[5:15] to 5:15 al
    // Magrib - Missing
    // Isha - Correct [9:00] to [9:00]
    // Juma - Missing

    // Directly accessing the image 10  from google_mlkit_text_recognition
    // Correct
    // Fajr Correct [4:15 ] to 4:I5 ill
    // Dhohr correct Missing
    // Asr Correct[5:15] to 5:I5 al
    // Magrib - correct [7:16] to [7:16]
    // Isha - Correct [9:00] to [9:00]
    // Juma - Missing
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    setState(() {
      _text = recognizedText.text;
      _prayerTimes.clear(); // Clear previous data
      _parsePrayerTimes(_text); // Parse the extracted text
    });

    textRecognizer.close();
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

  Future<void> toggleSharpness() async {
    if (_image != null) {
      _isSharpnessApplied = !_isSharpnessApplied;
      File modifiedImage = await applySharpness(_image!, _isSharpnessApplied);
      setState(() {
        _image = modifiedImage;
      });
      await performOCR(modifiedImage);
    }
  }

  Future<void> toggleContrast() async {
    if (_image != null) {
      _isContrastApplied = !_isContrastApplied;
      File modifiedImage = await applyContrast(_image!, _isContrastApplied);
      setState(() {
        _image = modifiedImage;
      });
      await performOCR(modifiedImage);
    }
  }

  Future<void> toggleGrayscale() async {
    if (_image != null) {
      _isGrayscaleApplied = !_isGrayscaleApplied;
      File modifiedImage = await applyGrayscale(_image!, _isGrayscaleApplied);
      setState(() {
        _image = modifiedImage;
      });
      await performOCR(modifiedImage);
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
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
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
                          onPressed: toggleSharpness,
                          child: Text(_isSharpnessApplied
                              ? "Remove Sharpness"
                              : "Add Sharpness"),
                        ),
                        ElevatedButton(
                          onPressed: toggleContrast,
                          child: Text(_isContrastApplied
                              ? "Remove Contrast"
                              : "Add Contrast"),
                        ),
                        ElevatedButton(
                          onPressed: toggleGrayscale,
                          child: Text(_isGrayscaleApplied
                              ? "Remove Grayscale"
                              : "Add Grayscale"),
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
