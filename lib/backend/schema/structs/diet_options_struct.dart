// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DietOptionsStruct extends BaseStruct {
  DietOptionsStruct({
    String? dietName,
    String? dietTagline,
  })  : _dietName = dietName,
        _dietTagline = dietTagline;

  // "diet_name" field.
  String? _dietName;
  String get dietName => _dietName ?? '';
  set dietName(String? val) => _dietName = val;

  bool hasDietName() => _dietName != null;

  // "diet_tagline" field.
  String? _dietTagline;
  String get dietTagline => _dietTagline ?? '';
  set dietTagline(String? val) => _dietTagline = val;

  bool hasDietTagline() => _dietTagline != null;

  static DietOptionsStruct fromMap(Map<String, dynamic> data) =>
      DietOptionsStruct(
        dietName: data['diet_name'] as String?,
        dietTagline: data['diet_tagline'] as String?,
      );

  static DietOptionsStruct? maybeFromMap(dynamic data) => data is Map
      ? DietOptionsStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'diet_name': _dietName,
        'diet_tagline': _dietTagline,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'diet_name': serializeParam(
          _dietName,
          ParamType.String,
        ),
        'diet_tagline': serializeParam(
          _dietTagline,
          ParamType.String,
        ),
      }.withoutNulls;

  static DietOptionsStruct fromSerializableMap(Map<String, dynamic> data) =>
      DietOptionsStruct(
        dietName: deserializeParam(
          data['diet_name'],
          ParamType.String,
          false,
        ),
        dietTagline: deserializeParam(
          data['diet_tagline'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'DietOptionsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is DietOptionsStruct &&
        dietName == other.dietName &&
        dietTagline == other.dietTagline;
  }

  @override
  int get hashCode => const ListEquality().hash([dietName, dietTagline]);
}

DietOptionsStruct createDietOptionsStruct({
  String? dietName,
  String? dietTagline,
}) =>
    DietOptionsStruct(
      dietName: dietName,
      dietTagline: dietTagline,
    );
