import 'dart:io';
import 'dart:ui';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salah_snap_version_second/pages/meals/dashboard/ImageToImage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dashboard_model.dart';
export 'dashboard_model.dart';
import 'package:image/image.dart' as img;

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  static String routeName = 'Dashboard';
  static String routePath = 'dashboard';

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  late DashboardModel _model;
  String extractedText = '';
  Future<void> setPrayerAlarms() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> alarms = [];

    for (var entry in _prayerTimes.entries) {
      final timeParts = entry.value.split(":");
      if (timeParts.length == 2) {
        int hour = int.tryParse(timeParts[0]) ?? 0;
        final int minute = int.tryParse(timeParts[1]) ?? 0;
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

        final formattedTime =
            '${entry.key}: ${hour > 12 ? hour - 12 : hour}:${minute.toString().padLeft(2, '0')} $period';

        alarms.add(formattedTime);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$formattedTime alarm set'),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.blue,
            ),
          );
        }

        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // ✅ Save to shared preferences
    await prefs.setStringList('set_alarms', alarms);

    // ✅ Update UI
    setState(() {
      _setAlarms = alarms;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFile(File(pickedFile.path));
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      setState(() {
        extractedText = recognizedText.text;
      });
    }
  }

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
  void showPrayerTimesPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Prayer Times"),
        content: _prayerTimes.isEmpty
            ? const Text("No prayer times available.")
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: _prayerOrder.map((prayer) {
                  final time = _prayerTimes[prayer['key']];
                  return time != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Text(
                                "${prayer['name']}: ",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                time,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink();
                }).toList(),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  final Map<String, String?> prayerTimes = {
    "Fajr": null,
    "Dhuhr": null,
    "Asr": null,
    "Maghrib": null,
    "Isha": null,
  };

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
      // Convert to grayscale
      File grayImage = await convertToGrayscale(File(pickedFile.path));

      // Show image in dialog immediately
      await showDialog(
        context: context,
        builder: (context) {
          final PageController pageController = PageController();
          int currentPage = 0;
          String extractedText = "";

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: currentPage == 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Set Alarm"),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  FlutterFlowTheme.of(context).primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              await setPrayerAlarms();
                              if (context.mounted) {
                                Navigator.of(context)
                                    .pop(); // ✅ Close popup after alarms
                              }
                            },
                            child: const Text("Set Alarms"),
                          ),
                        ],
                      )
                    : const Text("Captured Image"),

                content: SizedBox(
                  height: 400,
                  width: 300,
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (index) {
                      setState(() => currentPage = index);
                    },
                    children: [
                      // Page 1: Show image
                      Column(
                        children: [
                          const Text("Step 1: Image Preview"),
                          const SizedBox(height: 10),
                          Expanded(child: Image.file(grayImage)),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  showPrayerTimesPopup();
                                },
                                child: const Text("Change Image"),
                              ),
                              const SizedBox(width: 15),
                              ElevatedButton(
                                onPressed: () async {
                                  final inputImage =
                                      InputImage.fromFilePath(grayImage.path);
                                  final textRecognizer = TextRecognizer(
                                      script: TextRecognitionScript.latin);
                                  final RecognizedText recognizedText =
                                      await textRecognizer
                                          .processImage(inputImage);

                                  extractedText = recognizedText.text;
                                  textRecognizer.close();

                                  _parsePrayerTimes(extractedText);

                                  setState(() {
                                    _text = extractedText;
                                  });

                                  // ✅ Move to next page after processing
                                  pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: const Text("Process"),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Page 2: Editable prayer times
                      SingleChildScrollView(
                        child: Column(
                          children: _prayerOrder.map((prayer) {
                            final key = prayer['key']!;
                            final name = prayer['name']!;
                            final controller = TextEditingController(
                                text: _prayerTimes[key] ?? '');
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(width: 80, child: Text(name)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: "HH:mm",
                                      ),
                                      onChanged: (value) {
                                        _prayerTimes[key] = value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Dots below
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(2, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              currentPage == index ? Colors.blue : Colors.grey,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                ],
              );
            },
          );
        },
      );
    }
  }

  List<String> _setAlarms = [];

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

  void showImagePreviewWithText(File image, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Image & OCR Result"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(_image!),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DashboardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
    _loadSetAlarms();
  }

  Future<void> _loadSetAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAlarms = prefs.getStringList('set_alarms') ?? [];

    setState(() {
      _setAlarms = savedAlarms;
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        // floatingActionButton: Align(
        //   alignment: AlignmentDirectional(1.0, 1.0),
        //   child: Row(
        //     crossAxisAlignment: CrossAxisAlignment.end,
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       FloatingActionButton(
        //         onPressed: () {
        //           Navigator.of(context).push(
        //               MaterialPageRoute(builder: (context) => ImageToText()));
        //         },
        //         backgroundColor: FlutterFlowTheme.of(context).primary,
        //         elevation: 8.0,
        //         child: Icon(
        //           Icons.alarm,
        //           color: FlutterFlowTheme.of(context).info,
        //           size: 24.0,
        //         ),
        //       ),
        //       SizedBox(
        //         width: 20,
        //       ),
        //       FloatingActionButton(
        //         onPressed: _showImageSourceDialog,
        //         backgroundColor: FlutterFlowTheme.of(context).primary,
        //         elevation: 8.0,
        //         child: Icon(
        //           Icons.camera_alt,
        //           color: FlutterFlowTheme.of(context).info,
        //           size: 24.0,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Text(
              'Salat Snap',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FlutterFlowTheme.of(context)
                          .headlineMedium
                          .fontWeight,
                      fontStyle:
                          FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                    ),
                    color: FlutterFlowTheme.of(context).alternate,
                    fontSize: 30.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                  ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                  onPressed: () {
                    _showImageSourceDialog();
                  },
                  icon: Icon(Icons.camera_alt)),
            )
          ],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔸 Show message when no alarms are set
              if (_setAlarms.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      "Click a snap and set alarms",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // 🔹 Show alarm list if alarms exist
              if (_setAlarms.isNotEmpty) ...[
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _setAlarms.length,
                    itemBuilder: (context, index) {
                      return SizedBox(
                        height: 80,
                        child: Card(
                          color: FlutterFlowTheme.of(context).primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading:
                                const Icon(Icons.alarm, color: Colors.white),
                            title: Text(
                              _setAlarms[index],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
