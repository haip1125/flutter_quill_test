import 'dart:convert';

import 'package:flutter_quill/models/documents/document.dart';

extension DocumentEx on Document {
  static Document fromJson(String? str) {
    return str != null && str.isNotEmpty
        ? Document.fromJson(json.decode(str))
        : Document();
  }

  String toJsonStr() => json.encode(toDelta().toJson());

  bool isNotEmpty() => !isEmpty();
}
