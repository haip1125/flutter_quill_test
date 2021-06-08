import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

GlobalKey globalKey = GlobalKey();

Widget defaultEmbedBuilder(BuildContext context, quill.Embed node) {
  switch (node.value.type) {
    case 'image':
      final imageUrl = node.value.data;
      final size = MediaQuery.of(context).size;
      final image = imageUrl.startsWith('http')
          ? Image.network(imageUrl)
          : Image.memory(base64Decode(imageUrl));
      return Container(
        child: image,
        alignment: Alignment.centerLeft,
        height: size.height * 0.3,
      );
    case 'divider':
      return const Divider(thickness: 2);
    case 'scrollPosition':
      return  SizedBox.shrink(key: globalKey,);
    default:
      throw UnimplementedError(
        'Embeddable type "${node.value.type}" is not supported by default '
        'embed builder of QuillEditor. You must pass your own builder function '
        'to embedBuilder property of QuillEditor or QuillField widgets.',
      );
  }
}
