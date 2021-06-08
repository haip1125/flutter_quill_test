
import 'package:flutter/material.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:flutter_quill/widgets/delegate.dart';
import 'package:flutter_quill/widgets/editor.dart';
import 'package:quill_test/extension/extension.dart';
import 'package:quill_test/flutter_quill/custom_quill_toolbar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'embed_builder.dart';

class DefaultQuillField extends FormField<String> {
  DefaultQuillField({
    Key? key,
    required this.controller,
    this.scrollController,
    this.focusNode,
    this.expands = false,
    this.readOnly = false,
    this.autoFocus = false,
    this.height,
    this.labelText,
    this.padding = const EdgeInsets.all(8),
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) : super(
            key: key,
            onSaved: onSaved,
            validator: validator,
            initialValue: controller.document.toJsonStr(),
            builder: (FormFieldState<String> state) {
              controller.addListener(
                  () => state.didChange(controller.document.toJsonStr()));
              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) => child ?? const SizedBox.shrink(),
                child: QuillField(
                  decoration: InputDecoration(
                    labelText: labelText,
                    errorText: state.errorText,
                  ),
                  expands: expands,
                  controller: controller,
                  focusNode: focusNode,
                  autoFocus: autoFocus,
                  readOnly: readOnly,
                  showCursor: !readOnly,
                  maxHeight: height,
                  minHeight: height,
                  padding: padding,
                  toolbar: readOnly
                      ? const SizedBox.shrink()
                      : Container(
                          alignment: Alignment.centerLeft,
                          child: DefaultQuillToolbar(controller: controller),
                        ),
                  onLaunchUrl: (String url) async {
                    final result = await canLaunch(url);
                    if (result) {
                      await launch(url);
                    }
                  },
                  embedBuilder: defaultEmbedBuilder,
                ),
              );
            });

  final QuillController controller;
  final FocusNode? focusNode;
  final bool expands;
  final bool readOnly;
  final bool autoFocus;
  final double? height;
  final String? labelText;
  final EdgeInsetsGeometry padding;
  final ScrollController? scrollController;

  @override
  FormFieldState<String> createState() => FormFieldState<String>();
}

class QuillField extends StatefulWidget {
  const QuillField({
    Key? key,
    required this.controller,
    this.focusNode,
    this.scrollController,
    this.scrollable = true,
    this.padding = EdgeInsets.zero,
    this.autoFocus = false,
    this.showCursor = true,
    this.readOnly = false,
    this.enableInteractiveSelection = true,
    this.minHeight,
    this.maxHeight,
    this.expands = false,
    this.textCapitalization = TextCapitalization.sentences,
    this.keyboardAppearance = Brightness.light,
    this.scrollPhysics,
    this.onLaunchUrl,
    this.decoration,
    this.toolbar,
    this.embedBuilder,
  }) : super(key: key);

  final QuillController controller;
  final FocusNode? focusNode;
  final ScrollController? scrollController;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final bool autoFocus;
  final bool showCursor;
  final bool readOnly;
  final bool enableInteractiveSelection;
  final double? minHeight;
  final double? maxHeight;
  final bool expands;
  final TextCapitalization textCapitalization;
  final Brightness keyboardAppearance;
  final ScrollPhysics? scrollPhysics;
  final ValueChanged<String>? onLaunchUrl;
  final InputDecoration? decoration;
  final Widget? toolbar;
  final EmbedBuilder? embedBuilder;

  @override
  _QuillFieldState createState() => _QuillFieldState();
}

class _QuillFieldState extends State<QuillField> {
  late bool _focused;
  void _editorFocusChanged() {
    final focusNode = widget.focusNode;
    if (focusNode != null) {
      setState(() {
        _focused = focusNode.hasFocus;
      });
    }
  }

  bool get _hasFocus => widget.focusNode?.hasFocus ?? false;

  @override
  void initState() {
    super.initState();
    _focused = widget.focusNode?.hasFocus ?? false;
    widget.focusNode?.addListener(_editorFocusChanged);
  }

  @override
  void didUpdateWidget(covariant QuillField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_editorFocusChanged);
      widget.focusNode?.addListener(_editorFocusChanged);
      _focused = _hasFocus;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = SizedBox(
      height: widget.maxHeight,
      child: QuillEditor(
        controller: widget.controller,
        focusNode: widget.focusNode ?? FocusNode(),
        scrollController: widget.scrollController ?? ScrollController(),
        scrollable: widget.scrollable,
        padding: widget.padding,
        autoFocus: widget.autoFocus,
        showCursor: widget.showCursor,
        readOnly: widget.readOnly,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        minHeight: widget.minHeight,
        maxHeight: widget.maxHeight,
        expands: widget.expands,
        textCapitalization: widget.textCapitalization,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPhysics: widget.scrollPhysics,
        onLaunchUrl: widget.onLaunchUrl,
        embedBuilder: widget.embedBuilder ?? defaultEmbedBuilder,
      ),
    );

    final _toolbar = widget.toolbar;
    if (_toolbar != null) {
      child = Column(
        children: [
          child,
          Visibility(
            child: _toolbar,
            visible: _focused,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
          ),
        ],
      );
    }

    return AnimatedBuilder(
      animation:
          Listenable.merge(<Listenable?>[widget.focusNode, widget.controller]),
      builder: (BuildContext context, Widget? child) {
        return InputDecorator(
          decoration: _getEffectiveDecoration(),
          isFocused: _hasFocus,
          isEmpty: widget.controller.document.isEmpty(),
          child: child,
        );
      },
      child: child,
    );
  }

  InputDecoration _getEffectiveDecoration() {
    final effectiveDecoration = (widget.decoration ?? const InputDecoration())
        .applyDefaults(Theme.of(context).inputDecorationTheme)
        .copyWith(
          enabled: !widget.readOnly,
          hintMaxLines: widget.decoration?.hintMaxLines,
        );

    return effectiveDecoration;
  }
}
