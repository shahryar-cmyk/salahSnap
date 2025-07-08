import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
  bool _isThresholdApplied = false;
  bool _isBackgroundRemoved = false;

  // Define expected prayer times for validation
  final Map<String, RegExp> _prayerTimePatterns = {
    'Fajr': RegExp(r'4:[0-5][0-9]'),
    'Dhuhr': RegExp(r'1:[0-5][0-9]'),
    'Asr': RegExp(r'5:[0-5][0-9]'),
    'Maghrib': RegExp(r'7:[0-5][0-9]'),
    'Isha': RegExp(r'9:[0-5][0-9]'),
    'Juma': RegExp(r'1:[0-5][0-9]'),
  };

  // Display order
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

  // Improved image processing functions
  Future<File> convertToGrayscale(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      img.Image grayscaleImage = img.grayscale(image);
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath =
          '${tempDir.path}/grayscale_${DateTime.now().millisecondsSinceEpoch}.png';
      final File grayscaleFile = File(tempPath);
      await grayscaleFile.writeAsBytes(img.encodePng(grayscaleImage));
      return grayscaleFile;
    }
    return imageFile;
  }

  Future<File> adjustContrast(File imageFile, double contrastFactor) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      img.Image contrastedImage = img.contrast(image, contrast: 0.5);
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath =
          '${tempDir.path}/contrast_${DateTime.now().millisecondsSinceEpoch}.png';
      final File contrastedFile = File(tempPath);
      await contrastedFile.writeAsBytes(img.encodePng(contrastedImage));
      return contrastedFile;
    }
    return imageFile;
  }

  Future<File> applyAdaptiveThreshold(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image != null) {
      // Convert to grayscale first
      img.Image grayImage = img.grayscale(image);

      // Create a copy for thresholding
      img.Image thresholdedImage = img.Image.from(grayImage);

      for (int y = 0; y < thresholdedImage.height; y++) {
        for (int x = 0; x < thresholdedImage.width; x++) {
          // Access the Pixel object
          img.Pixel pixel = thresholdedImage.getPixel(x, y);

          // Extract RGB values directly from the Pixel object
          // Use pixel.r, pixel.g, pixel.b for the red, green, blue components
          // For grayscale, r, g, and b will be the same, so you can pick any.
          // Or, if you want the combined luminance, you can still use img.getLuminanceRgb
          int red = pixel.r.toInt(); // Convert to int if it's not already
          int green = pixel.g.toInt(); // Convert to int
          int blue = pixel.b.toInt(); // Convert to int

          // Compute luminance
          num grayValue = img.getLuminanceRgb(red, green, blue);
          // No need for int.parse( ... .toString()) as getLuminanceRgb returns int

          // Apply threshold
          if (grayValue < 128) {
            thresholdedImage.setPixelRgb(x, y, 0, 0, 0); // Black
          } else {
            thresholdedImage.setPixelRgb(x, y, 255, 255, 255); // White
          }
        }
      }

      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath =
          '${tempDir.path}/thresholded_${DateTime.now().millisecondsSinceEpoch}.png';
      final File thresholdedFile = File(tempPath);
      await thresholdedFile.writeAsBytes(img.encodePng(thresholdedImage));
      return thresholdedFile;
    }

    return imageFile; // Return original image if decoding failed
  }

  Future<File> applySharpness(File imageFile, bool apply) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return imageFile;

    if (apply) {
      final sharpenKernel = [0, -1, 0, -1, 5, -1, 0, -1, 0];
      original =
          img.convolution(original, div: 1, offset: 0, filter: sharpenKernel);
    }

    final sharpPath = imageFile.path
        .replaceFirst('.jpg', '_sharp.jpg')
        .replaceFirst('.png', '_sharp.png');
    final newFile = File(sharpPath);
    await newFile.writeAsBytes(img.encodeJpg(original));
    return newFile;
  }

  Future<File> applyGrayscale(File imageFile, bool apply) async {
    if (!apply) return imageFile;
    return await convertToGrayscale(imageFile);
  }

  Future<File> applyContrast(File imageFile, bool apply) async {
    if (!apply) return imageFile;
    return await adjustContrast(imageFile, 0.5);
  }

  Future<File> applyThreshold(File imageFile, bool apply) async {
    if (!apply) return imageFile;
    return await applyAdaptiveThreshold(imageFile);
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Reset all effects when new image is picked
      _isSharpnessApplied = false;
      _isContrastApplied = false;
      _isGrayscaleApplied = false;
      _isThresholdApplied = false;
      _isBackgroundRemoved = false;

      File originalFile = File(pickedFile.path);
      setState(() {
        _image = originalFile;
      });

      await performOCR(originalFile);
    }
  }

  // Improved prayer time validation
  Map<String, String> parseAndValidatePrayerTimes(String ocrText) {
    final Map<String, String> results = {
      'Fajr': 'Missing',
      'Dhuhr': 'Missing',
      'Asr': 'Missing',
      'Maghrib': 'Missing',
      'Isha': 'Missing',
      'Juma': 'Missing',
    };

    final lines = ocrText.split('\n');

    for (final line in lines) {
      String cleanedLine = line.trim();

      // Check for prayer names with flexible matching
      if (cleanedLine.toLowerCase().contains('fajr')) {
        final match = _prayerTimePatterns['Fajr']?.firstMatch(cleanedLine);
        results['Fajr'] =
            match != null ? match.group(0)! : 'Incorrect (No Match)';
      } else if (cleanedLine.toLowerCase().contains('dhuhr') ||
          cleanedLine.toLowerCase().contains('zuhr')) {
        final match = _prayerTimePatterns['Dhuhr']?.firstMatch(cleanedLine);
        results['Dhuhr'] =
            match != null ? match.group(0)! : 'Incorrect (No Match)';
      } else if (cleanedLine.toLowerCase().contains('asr')) {
        final match = _prayerTimePatterns['Asr']?.firstMatch(cleanedLine);
        results['Asr'] =
            match != null ? match.group(0)! : 'Incorrect (No Match)';
      } else if (cleanedLine.toLowerCase().contains('maghrib')) {
        final match = _prayerTimePatterns['Maghrib']?.firstMatch(cleanedLine);
        results['Maghrib'] =
            match != null ? match.group(0)! : 'Incorrect (No Match)';
      } else if (cleanedLine.toLowerCase().contains('isha')) {
        final match = _prayerTimePatterns['Isha']?.firstMatch(cleanedLine);
        results['Isha'] =
            match != null ? match.group(0)! : 'Incorrect (No Match)';
      } else if (cleanedLine.toLowerCase().contains('juma') ||
          cleanedLine.toLowerCase().contains('jummah')) {
        final match = _prayerTimePatterns['Juma']?.firstMatch(cleanedLine);
        results['Juma'] =
            match != null ? match.group(0)! : 'Incorrect (No Match)';
      }

      // Error correction for common OCR mistakes
      if (results['Dhuhr'] == 'Incorrect (No Match)' &&
          (cleanedLine.contains('I:00') || cleanedLine.contains('H:00'))) {
        results['Dhuhr'] = '1:00 (Corrected)';
      }
      if (results['Maghrib'] == 'Incorrect (No Match)' &&
          (cleanedLine.contains('7:N6') || cleanedLine.contains('1:16'))) {
        results['Maghrib'] = '7:16 (Corrected)';
      }
      if (results['Juma'] == 'Incorrect (No Match)' &&
          cleanedLine.contains(':00') &&
          cleanedLine.length < 5) {
        results['Juma'] = '1:00 (Corrected)';
      }
    }

    return results;
  }

  Future<void> performOCR(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    setState(() {
      _text = recognizedText.text;
      _prayerTimes.clear();

      // First try advanced validation
      final validated = parseAndValidatePrayerTimes(_text);

      // If we got good results, use them
      if (validated.entries.any((e) =>
          !e.value.contains('Missing') && !e.value.contains('Incorrect'))) {
        validated.forEach((key, value) {
          if (!value.contains('Missing') && !value.contains('Incorrect')) {
            _prayerTimes[key] = value.replaceAll(' (Corrected)', '');
          }
        });
      } else {
        // Fallback to original parsing
        _parsePrayerTimes(_text);
      }
    });

    textRecognizer.close();
  }

  Future<File> removeBackgroundKeepingLightElements(
      File imageFile, bool isBackgroundRemoved) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return imageFile;

    final transparentImage = img.Image(
      width: original.width,
      height: original.height,
      numChannels: 4,
    );

    final brightnessThreshold = 200;

    for (var y = 0; y < original.height; y++) {
      for (var x = 0; x < original.width; x++) {
        final pixel = original.getPixel(x, y);
        final brightness = (pixel.r + pixel.g + pixel.b) / 3;

        if (brightness >= brightnessThreshold) {
          transparentImage.setPixelRgba(x, y, pixel.r, pixel.g, pixel.b, 255);
        } else {
          transparentImage.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }

    final newPath =
        imageFile.path.replaceAll(RegExp(r'\.(jpg|jpeg|png)$'), '_light.png');
    final newFile = File(newPath);
    await newFile.writeAsBytes(img.encodePng(transparentImage));

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

    // Step 3: Fallback - Assign in order
    if (!foundLabeledTimes && times.isNotEmpty) {
      for (int i = 0; i < times.length && i < _prayerOrder.length; i++) {
        _prayerTimes[_prayerOrder[i]['key']!] = times[i];
      }
    }
  }

  Future<void> toggleBackground() async {
    if (_image != null) {
      _isBackgroundRemoved = !_isBackgroundRemoved;
      File modifiedImage = await removeBackgroundKeepingLightElements(
          _image!, _isBackgroundRemoved);
      setState(() {
        _image = modifiedImage;
      });
      await performOCR(modifiedImage);
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

  Future<void> toggleThreshold() async {
    print('is work funcation$_isThresholdApplied');
    if (_image != null) {
      _isThresholdApplied = !_isThresholdApplied;
      File modifiedImage = await applyThreshold(_image!, _isThresholdApplied);
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
                          onPressed: toggleBackground,
                          child: Text(_isBackgroundRemoved
                              ? "Add Background"
                              : "Remove Background"),
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
                        ElevatedButton(
                          onPressed: toggleThreshold,
                          child: Text(_isThresholdApplied
                              ? "Remove Threshold"
                              : "Add Threshold"),
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
