// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ChefsStruct extends BaseStruct {
  ChefsStruct({
    String? profilePicture,
    String? name,
    String? bio,
  })  : _profilePicture = profilePicture,
        _name = name,
        _bio = bio;

  // "profile_picture" field.
  String? _profilePicture;
  String get profilePicture => _profilePicture ?? '';
  set profilePicture(String? val) => _profilePicture = val;

  bool hasProfilePicture() => _profilePicture != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "bio" field.
  String? _bio;
  String get bio => _bio ?? '';
  set bio(String? val) => _bio = val;

  bool hasBio() => _bio != null;

  static ChefsStruct fromMap(Map<String, dynamic> data) => ChefsStruct(
        profilePicture: data['profile_picture'] as String?,
        name: data['name'] as String?,
        bio: data['bio'] as String?,
      );

  static ChefsStruct? maybeFromMap(dynamic data) =>
      data is Map ? ChefsStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'profile_picture': _profilePicture,
        'name': _name,
        'bio': _bio,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'profile_picture': serializeParam(
          _profilePicture,
          ParamType.String,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'bio': serializeParam(
          _bio,
          ParamType.String,
        ),
      }.withoutNulls;

  static ChefsStruct fromSerializableMap(Map<String, dynamic> data) =>
      ChefsStruct(
        profilePicture: deserializeParam(
          data['profile_picture'],
          ParamType.String,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        bio: deserializeParam(
          data['bio'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'ChefsStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is ChefsStruct &&
        profilePicture == other.profilePicture &&
        name == other.name &&
        bio == other.bio;
  }

  @override
  int get hashCode => const ListEquality().hash([profilePicture, name, bio]);
}

ChefsStruct createChefsStruct({
  String? profilePicture,
  String? name,
  String? bio,
}) =>
    ChefsStruct(
      profilePicture: profilePicture,
      name: name,
      bio: bio,
    );
