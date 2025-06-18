import '/components/custom_appbar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'onboarding_widget.dart' show OnboardingWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OnboardingModel extends FlutterFlowModel<OnboardingWidget> {
  ///  Local state fields for this page.

  List<String> allergenSelection = [];
  void addToAllergenSelection(String item) => allergenSelection.add(item);
  void removeFromAllergenSelection(String item) =>
      allergenSelection.remove(item);
  void removeAtIndexFromAllergenSelection(int index) =>
      allergenSelection.removeAt(index);
  void insertAtIndexInAllergenSelection(int index, String item) =>
      allergenSelection.insert(index, item);
  void updateAllergenSelectionAtIndex(int index, Function(String) updateFn) =>
      allergenSelection[index] = updateFn(allergenSelection[index]);

  String? dietSelection;

  List<String> ingredientSelection = [];
  void addToIngredientSelection(String item) => ingredientSelection.add(item);
  void removeFromIngredientSelection(String item) =>
      ingredientSelection.remove(item);
  void removeAtIndexFromIngredientSelection(int index) =>
      ingredientSelection.removeAt(index);
  void insertAtIndexInIngredientSelection(int index, String item) =>
      ingredientSelection.insert(index, item);
  void updateIngredientSelectionAtIndex(int index, Function(String) updateFn) =>
      ingredientSelection[index] = updateFn(ingredientSelection[index]);

  ///  State fields for stateful widgets in this page.

  // Model for customAppbar component.
  late CustomAppbarModel customAppbarModel;
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // State field(s) for Switch widget.
  bool? switchValue1;
  // State field(s) for Switch widget.
  bool? switchValue2;
  // State field(s) for Switch widget.
  bool? switchValue3;
  // State field(s) for Switch widget.
  bool? switchValue4;
  // State field(s) for Switch widget.
  bool? switchValue5;

  @override
  void initState(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }

  @override
  void dispose() {
    customAppbarModel.dispose();
  }
}
