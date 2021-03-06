import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/models/documents/document.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'flutter_quill/default_quill_editor.dart';
import 'flutter_quill/embed_builder.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // debugShowMaterialGrid: true,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool defaultEditor = true;
  @override
  Widget build(BuildContext context) {
    final AutoScrollController scrollController = AutoScrollController();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('test'),
      ),
      body: _Editor(
        scrollController: scrollController,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await scrollController.scrollToIndex(
            'video1'.hashCode,
            preferPosition: AutoScrollPosition.begin,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _Editor extends StatefulWidget {
  const _Editor({
    Key? key,
    required this.scrollController,
  }) : super(key: key);
  final AutoScrollController scrollController;

  @override
  __EditorState createState() => __EditorState();
}

class __EditorState extends State<_Editor> {
  QuillController? _controller;

  @override
  void initState() {
    super.initState();
    _loadFromAssets();
  }

  Future<void> _loadFromAssets() async {
    try {
      final result = await rootBundle.loadString('assets/sample_data.json');
      final doc = Document.fromJson(jsonDecode(result));
      setState(() {
        _controller = QuillController(
            document: doc, selection: const TextSelection.collapsed(offset: 0));
      });
    } catch (error) {
      final doc = Document()..insert(0, 'Empty asset');
      setState(() {
        _controller = QuillController(
            document: doc, selection: const TextSelection.collapsed(offset: 0));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: Text('Loading...'));
    }
    // _controller?.addListener(() {
    //   print('-------');
    //   print(_controller?.document.toDelta().toJson());
    // });
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  height: 100,
                  color: Colors.black12,
                ),
                DefaultQuillEditor(
                  controller: _controller!,
                  minHeight: 500,
                  scrollController: widget.scrollController,
                  editorPositionTop: 100 + 8,
                  readOnly: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
