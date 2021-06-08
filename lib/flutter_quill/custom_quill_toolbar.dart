import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../extension/extension.dart';

class DefaultQuillToolbar extends StatelessWidget {
  const DefaultQuillToolbar({
    Key? key,
    required this.controller,
    this.toolbarIconSize = kDefaultIconSize,
    this.showImageButton = false,
    this.maxImage = 5,
  }) : super(key: key);

  final QuillController controller;
  final double toolbarIconSize;
  final bool showImageButton;
  final int maxImage;

  @override
  Widget build(BuildContext context) {
    return QuillToolbar(
      key: key,
      toolBarHeight: toolbarIconSize * 2,
      children: [
        HistoryButton(
          icon: Icons.undo_outlined,
          iconSize: toolbarIconSize,
          controller: controller,
          undo: true,
        ),
        HistoryButton(
          icon: Icons.redo_outlined,
          iconSize: toolbarIconSize,
          controller: controller,
          undo: false,
        ),
        ToggleStyleButton(
          attribute: Attribute.bold,
          icon: Icons.format_bold,
          iconSize: toolbarIconSize,
          controller: controller,
        ),
        ToggleStyleButton(
          attribute: Attribute.italic,
          icon: Icons.format_italic,
          iconSize: toolbarIconSize,
          controller: controller,
        ),
        ToggleStyleButton(
          attribute: Attribute.underline,
          icon: Icons.format_underline,
          iconSize: toolbarIconSize,
          controller: controller,
        ),
        ToggleStyleButton(
          attribute: Attribute.strikeThrough,
          icon: Icons.format_strikethrough,
          iconSize: toolbarIconSize,
          controller: controller,
        ),
        ColorButton(
          icon: Icons.color_lens,
          iconSize: toolbarIconSize,
          controller: controller,
          background: false,
        ),
        ColorButton(
          icon: Icons.format_color_fill,
          iconSize: toolbarIconSize,
          controller: controller,
          background: true,
        ),
        ClearFormatButton(
          icon: Icons.format_clear,
          iconSize: toolbarIconSize,
          controller: controller,
        ),
        if (showImageButton)
          _ImageButton(
            icon: Icons.image,
            iconSize: toolbarIconSize,
            controller: controller,
            maxImage: maxImage,
          ),
        VerticalDivider(
          indent: 12,
          endIndent: 12,
          color: Colors.grey.shade400,
        ),
        SelectHeaderStyleButton(
          controller: controller,
          iconSize: toolbarIconSize,
        ),
        VerticalDivider(
          indent: 12,
          endIndent: 12,
          color: Colors.grey.shade400,
        ),
        ToggleStyleButton(
          attribute: Attribute.ol,
          controller: controller,
          icon: Icons.format_list_numbered,
          iconSize: toolbarIconSize,
        ),
        ToggleStyleButton(
          attribute: Attribute.ul,
          controller: controller,
          icon: Icons.format_list_bulleted,
          iconSize: toolbarIconSize,
        ),
        ToggleCheckListButton(
          attribute: Attribute.unchecked,
          controller: controller,
          icon: Icons.check_box,
          iconSize: toolbarIconSize,
        ),
        ToggleStyleButton(
          attribute: Attribute.codeBlock,
          controller: controller,
          icon: Icons.code,
          iconSize: toolbarIconSize,
        ),
        VerticalDivider(
          indent: 12,
          endIndent: 12,
          color: Colors.grey.shade400,
        ),
        ToggleStyleButton(
          attribute: Attribute.blockQuote,
          controller: controller,
          icon: Icons.format_quote,
          iconSize: toolbarIconSize,
        ),
        IndentButton(
          icon: Icons.format_indent_increase,
          iconSize: toolbarIconSize,
          controller: controller,
          isIncrease: true,
        ),
        IndentButton(
          icon: Icons.format_indent_decrease,
          iconSize: toolbarIconSize,
          controller: controller,
          isIncrease: false,
        ),
        VerticalDivider(
          indent: 12,
          endIndent: 12,
          color: Colors.grey.shade400,
        ),
        LinkStyleButton(
          controller: controller,
          iconSize: toolbarIconSize,
        ),
        InsertEmbedButton(
          controller: controller,
          icon: Icons.horizontal_rule,
          iconSize: toolbarIconSize,
        ),
      ],
    );
  }
}

class _ImageButton extends StatelessWidget {
  const _ImageButton({
    Key? key,
    required this.icon,
    required this.iconSize,
    required this.controller,
    this.fillColor,
    this.maxImage,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final Color? fillColor;
  final QuillController controller;
  final int? maxImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return QuillIconButton(
      icon: Icon(icon, size: iconSize, color: theme.iconTheme.color),
      highlightElevation: 0,
      hoverElevation: 0,
      size: iconSize * 1.77,
      fillColor: fillColor ?? theme.canvasColor,
      onPressed: controller.imageCount > (maxImage ?? double.infinity)
          ? null
          : () => _handleImageButtonTap(context),
    );
  }

  Future<void> _handleImageButtonTap(BuildContext context) async {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null) {
      return;
    }
    final file = result.files.first;

    final imageUrl = base64Encode(file.bytes!);

    controller.replaceText(index, length, BlockEmbed.image(imageUrl), null);
  }
}
