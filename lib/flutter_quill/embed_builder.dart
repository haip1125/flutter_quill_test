import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:scroll_to_index/scroll_to_index.dart';

Widget defaultEmbedBuilder(BuildContext context, quill.Embed node,
    {AutoScrollController? scrollController}) {
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
      if (scrollController == null) {
        return SizedBox.shrink();
      }
      final String targetKey = node.value.data;
      return AutoScrollTag(
          key: Key(targetKey),
          controller: scrollController,
          index: targetKey.hashCode,
          child: SizedBox.shrink(),);
    default:
      throw UnimplementedError(
        'Embeddable type "${node.value.type}" is not supported by default '
        'embed builder of QuillEditor. You must pass your own builder function '
        'to embedBuilder property of QuillEditor or QuillField widgets.',
      );
  }
}
