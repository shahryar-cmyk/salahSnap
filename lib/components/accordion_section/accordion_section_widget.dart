import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'accordion_section_model.dart';
export 'accordion_section_model.dart';

class AccordionSectionWidget extends StatefulWidget {
  const AccordionSectionWidget({super.key});

  @override
  State<AccordionSectionWidget> createState() => _AccordionSectionWidgetState();
}

class _AccordionSectionWidgetState extends State<AccordionSectionWidget> {
  late AccordionSectionModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AccordionSectionModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [],
    );
  }
}
