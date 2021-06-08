import 'package:flutter/material.dart';
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';

extension QuillControllerEx on QuillController {
  static const document = _QuillControllerBuilder();

  int get imageCount {
    return this.document.toDelta().toList().where((e) {
      if (e.key == 'insert') {
        final data = e.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('image')) {
            return true;
          }
        }
      }
      return false;
    }).length;
  }
}

class _QuillControllerBuilder {
  const _QuillControllerBuilder();

  QuillController call(Document document) => QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );
}
