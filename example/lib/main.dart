import 'package:example/editor.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Node;
import 'package:flutter_quill/quill_delta.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: DesktopTreeViewExample());
  }
}

class DesktopTreeViewExample extends StatefulWidget {
  const DesktopTreeViewExample({super.key});

  @override
  State<DesktopTreeViewExample> createState() => _DesktopTreeViewExampleState();
}

class _DesktopTreeViewExampleState extends State<DesktopTreeViewExample> {
  final QuillController _controller = QuillController.basic();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  Delta oldVersion = Delta();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            QuillSimpleToolbar(controller: _controller, config: const QuillSimpleToolbarConfig()),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 10, top: size.height * 0.17, bottom: 10),
              child: MyEditor(
                controller: _controller,
                scrollController: _scrollController,
                configurations: const QuillEditorConfig(
                  placeholder: 'Write something',
                  scrollable: true,
                  expands: true,
                ),
                focusNode: _focusNode,
                onChange: (Document document) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
