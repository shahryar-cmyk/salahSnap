import 'package:android_intent_plus/android_intent.dart';
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

  /// ⬇️ Pick image & perform full OCR + parsing
  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Step 1: Convert to grayscale
      File grayImage = await convertToGrayscale(File(pickedFile.path));

      // Step 2: OCR using ML Kit
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

  Future<void> setPrayerAlarms() async {
    for (var entry in _prayerTimes.entries) {
      final timeParts = entry.value.split(":");
      if (timeParts.length == 2) {
        int hour = int.tryParse(timeParts[0]) ?? 0;
        final minute = int.tryParse(timeParts[1]) ?? 0;
        bool isAm = false;
        String period = 'AM';
        if (entry.key == 'Fajr') {
          isAm = true;
          period = 'AM';
          if (hour == 0) hour = 12;
        } else {
          period = 'PM';
          if (hour < 12) hour += 12;
          if (hour == 24) hour = 12;
        }

        final alarmIntent = AndroidIntent(
          action: 'android.intent.action.SET_ALARM',
          arguments: <String, dynamic>{
            'android.intent.extra.alarm.HOUR': hour,
            'android.intent.extra.alarm.MINUTES': minute,
            'android.intent.extra.alarm.MESSAGE':
                '${entry.key} Prayer ($period)',
            'android.intent.extra.alarm.SKIP_UI': true,
          },
        );

        await alarmIntent.launch();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${entry.key} alarm set for ${hour > 12 ? hour - 12 : hour}:${minute.toString().padLeft(2, '0')} $period'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.blue,
            ),
          );
        }
        await Future.delayed(const Duration(seconds: 2));
      }
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

    final Map<String, String> knownLabels = {
      "الفجر": "Fajr",
      "الظهر": "Dhuhr",
      "العصر": "Asr",
      "المغرب": "Maghrib",
      "العشاء": "Isha",
    };

    final timeRegex = RegExp(r'(\d{1,2})[:٫](\d{2})');

    for (final line in lines) {
      final cleanLine = convertArabicToEnglishDigits(line);
      final match = timeRegex.firstMatch(cleanLine);
      if (match != null) {
        final hour = match.group(1);
        final minute = match.group(2);
        times.add('$hour:$minute');
      }
    }

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

    if (!foundLabeledTimes && times.isNotEmpty) {
      for (int i = 0; i < times.length && i < _prayerOrder.length; i++) {
        _prayerTimes[_prayerOrder[i]['key']!] = times[i];
      }
    }
  }

  /// ⬇️ Show editable prayer time dialog
  void showEditPrayerTimesDialog() {
    final Map<String, TextEditingController> controllers = {
      for (var prayer in _prayerOrder)
        prayer['key']!: TextEditingController(
          text: _prayerTimes[prayer['key']!] ?? '',
        ),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Prayer Times"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _prayerOrder.map((prayer) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: TextField(
                  controller: controllers[prayer['key']!],
                  decoration: InputDecoration(
                    labelText: prayer['name'],
                    border: const OutlineInputBorder(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                for (var prayer in _prayerOrder) {
                  _prayerTimes[prayer['key']!] =
                      controllers[prayer['key']!]!.text.trim();
                }
              });
              Navigator.of(context).pop();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
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
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _text = _text.replaceAll(RegExp(r'[a-zA-Z]'), '');
                        });
                      },
                      child: const Text("Remove alphabets"),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_text.isNotEmpty) ...[
                    GestureDetector(
                      onTap: showEditPrayerTimesDialog,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Raw Extracted Text (Tap to edit times):",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_text),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
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
                  ElevatedButton(
                    onPressed: () {
                      setPrayerAlarms();
                    },
                    child: const Text("Set Alarm"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
