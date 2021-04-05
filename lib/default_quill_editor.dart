import 'package:flutter/material.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:flutter_quill/widgets/toolbar.dart';
import 'package:url_launcher/url_launcher.dart';

class DefaultQuillEditor extends StatefulWidget {
  const DefaultQuillEditor({
    Key? key,
    this.controller,
    this.scrollController,
    this.offset,
    this.focusNode,
    this.expands = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.maxHeight,
    this.minHeight,
    this.padding = const EdgeInsets.all(8),
  })  : assert(!(scrollController != null && offset == null ||
            scrollController == null && offset != null)),
        super(key: key);

  final QuillController? controller;
  final FocusNode? focusNode;
  final bool expands;
  final bool readOnly;
  final bool autoFocus;
  final double? maxHeight;
  final double? minHeight;
  final EdgeInsetsGeometry padding;
  final ScrollController? scrollController;
  final double? offset;

  @override
  _DefaultQuillEditorState createState() => _DefaultQuillEditorState();
}

class _DefaultQuillEditorState extends State<DefaultQuillEditor> {
  double? top;
  @override
  Widget build(BuildContext context) {
    final QuillController controller =
        widget.controller ?? QuillController.basic();
    final FocusNode focusNode = widget.focusNode ?? FocusNode();
    final bool expands = widget.expands;
    final bool readOnly = widget.readOnly;
    final bool autoFocus = widget.autoFocus;
    final double? maxHeight = widget.maxHeight;
    final double? minHeight = widget.minHeight;
    final EdgeInsetsGeometry padding = widget.padding;
    final ScrollController scrollController =
        widget.scrollController ?? ScrollController();
    final double? offset = widget.offset;

    scrollController.addListener(() {
      if (offset != null) {
        setState(() {
          top = scrollController.offset - offset >= 0
              ? scrollController.offset - offset
              : 0;
        });
      }
    });

    controller.addListener(() => print(controller.document.toString()));

    return Column(
      children: [
        if (!readOnly)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                QuillToolbar.basic(
                  controller: controller,
                  showClearFormat: false,
                ),
                Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
              ],
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: QuillEditor(
            expands: expands,
            controller: controller,
            focusNode: focusNode,
            autoFocus: autoFocus,
            readOnly: readOnly,
            showCursor: !readOnly,
            maxHeight: maxHeight,
            minHeight: minHeight,
            padding: padding,
            onLaunchUrl: (String url) async {
              final result = await canLaunch(url);
              if (result) {
                await launch(url);
              }
            },
            scrollable: true,
            scrollController: scrollController,
            enableInteractiveSelection: true,
          ),
        ),
      ],
    );
  }
}
