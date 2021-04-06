import 'package:flutter/material.dart';
import 'package:flutter_quill/widgets/controller.dart';
import 'package:quill_test/default_quill_editor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    QuillController _controller = QuillController.basic();
    ScrollController scrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          controller: scrollController,
          // physics: NeverScrollableScrollPhysics(),
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
                    controller: _controller,
                    maxHeight: 800,
                    minHeight: 800,
                    scrollController: scrollController,
                    editorPositionTop: 100,
                  ),
                  Divider(height: 5, thickness: 10, color: Colors.black),
                  TextField(
                    maxLines: null,
                    showCursor: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
