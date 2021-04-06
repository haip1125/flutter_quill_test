import 'package:flutter/foundation.dart';
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

  final QuillController? controller;
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

    controller.addListener(() {});

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
      scrollController: ScrollController(),
      scrollable: true,
      enableInteractiveSelection: true,
    );

    if (kIsWeb) {
      quillEditor = Shortcuts(
        shortcuts: scrollShortcutOverrides,
        child: quillEditor,
      );
    }
    return LayoutBuilder(
      builder: (_, constraint) => Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            padding: EdgeInsets.only(top: readOnly ? 0 : 48),
            child: quillEditor,
          ),
          if (!readOnly)
            Positioned(
              top: top,
              width: constraint.maxWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                child: Column(
                  children: [
                    QuillToolbar.basic(
                      controller: controller,
                      showClearFormat: false,
                      // showHeaderStyle: false,
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
      ),
    );
  }
}
