import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:quill_test/flutter_quill/custom_quill_toolbar.dart';
import 'package:quill_test/flutter_quill/embed_builder.dart';
import 'package:url_launcher/url_launcher.dart';

class DefaultQuillEditor extends StatefulWidget {
  const DefaultQuillEditor({
    Key? key,
    required this.controller,
    this.scrollController,
    this.editorPositionTop,
    this.focusNode,
    this.expands = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.maxHeight,
    this.minHeight,
    this.padding = const EdgeInsets.all(8),
  })  : assert(!(scrollController != null && editorPositionTop == null ||
            scrollController == null && editorPositionTop != null)),
        super(key: key);

  final QuillController controller;
  final FocusNode? focusNode;
  final bool expands;
  final bool readOnly;
  final bool autoFocus;
  final double? maxHeight;
  final double? minHeight;
  final EdgeInsetsGeometry padding;
  final ScrollController? scrollController;
  final double? editorPositionTop;

  @override
  _DefaultQuillEditorState createState() => _DefaultQuillEditorState();
}

class _DefaultQuillEditorState extends State<DefaultQuillEditor> {
  double? top;

  void _scrollListener() {
    if (widget.readOnly) {
      return;
    }
    final double? editorPositionTop = widget.editorPositionTop;
    if (editorPositionTop != null) {
      setState(() {
        top = (widget.scrollController!.offset - editorPositionTop)
            .clamp(0, double.infinity);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_scrollListener);
  }

  @override
  void didUpdateWidget(covariant DefaultQuillEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_scrollListener);
      widget.scrollController?.addListener(_scrollListener);
    }
  }

  @override
  void dispose() {
    super.dispose();
    widget.scrollController?.removeListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final QuillController controller = widget.controller;
    final FocusNode focusNode = widget.focusNode ?? FocusNode();
    final bool expands = widget.expands;
    final bool readOnly = widget.readOnly;
    final bool autoFocus = widget.autoFocus;
    final double? maxHeight = widget.maxHeight;
    final double? minHeight = widget.minHeight;
    final EdgeInsetsGeometry padding = widget.padding;
    final ScrollController scrollController =
        widget.scrollController ?? ScrollController();
    final scrollable = widget.scrollController == null;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          padding: EdgeInsets.only(top: readOnly ? 0 : 48),
          child: _Editor(
            controller: controller,
            focusNode: focusNode,
            expands: expands,
            readOnly: readOnly,
            autoFocus: autoFocus,
            maxHeight: maxHeight,
            minHeight: minHeight,
            padding: padding,
            scrollable: scrollable,
            scrollController: scrollController,
          ),
        ),
        if (!readOnly)
          Positioned(
            top: top,
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Column(
                children: [
                  DefaultQuillToolbar(
                    controller: controller,
                    showImageButton: true,
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({
    Key? key,
    required this.controller,
    required this.scrollController,
    required this.focusNode,
    this.expands = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.maxHeight,
    this.minHeight,
    required this.padding,
    required this.scrollable,
  }) : super(key: key);

  final QuillController controller;
  final FocusNode focusNode;
  final bool expands;
  final bool readOnly;
  final bool autoFocus;
  final double? maxHeight;
  final double? minHeight;
  final EdgeInsetsGeometry padding;
  final ScrollController scrollController;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    Widget quillEditor = QuillEditor(
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
      scrollController: scrollController,
      scrollable: scrollable,
      enableInteractiveSelection: true,
      onTapDown: (TapDownDetails details, getPosition) {
        focusNode.requestFocus();
        return false;
      },
      embedBuilder: defaultEmbedBuilder,
    );
    if (kIsWeb) {
      quillEditor = Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.space):
              DoNothingAndStopPropagationIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowUp):
              DoNothingAndStopPropagationIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowDown):
              DoNothingAndStopPropagationIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowLeft):
              DoNothingAndStopPropagationIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowRight):
              DoNothingAndStopPropagationIntent(),
        },
        child: quillEditor,
      );
    }

    return quillEditor;
  }
}
