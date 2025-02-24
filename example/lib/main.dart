import 'dart:io';
import 'dart:typed_data';

import 'package:docx_transformer/docx_transformer.dart';
import 'package:example/editor.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Node;
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Body(), localizationsDelegates: [FlutterQuillLocalizations.delegate]);
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _DesktopTreeViewExampleState();
}

class _DesktopTreeViewExampleState extends State<Body> {
  final QuillController _controller = QuillController.basic();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  void _loadDocxDocument() async {
    final XFile? file = await openFile(
      confirmButtonText: 'Take docx',
      acceptedTypeGroups: [
        XTypeGroup(label: 'DOCX', extensions: ['docx', 'doc']),
      ],
    );
    if (file != null) {
      final Delta? delta =
          await DeltaFromDocxParser(
            data: await file.readAsBytes(),
            options: DeltaParserOptions(
              ignoreColorWhenNoSupported: true,
              onDetectImage: (Uint8List imageBytes, String name) async {
                final String path = (await getTemporaryDirectory()).path;
                final File file = File(join(path, name));
                if (!(await file.exists())) {
                  await file.writeAsBytes(imageBytes);
                }
                return file.path;
              },
              shouldParserSizeToHeading: (String value) {
                return null;
              },
            ),
          ).build();
      if (delta != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.document = Document.fromDelta(delta);
          setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Stack(
        children: [
          Positioned(
            left: 10,
            top: 10,
            child: Row(
              children: [
                MaterialButton(
                  onPressed: () async {
                    _loadDocxDocument();
                  },
                  child: Text('select a docx file'),
                ),
                const SizedBox.shrink(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, top: 40),
            child: QuillSimpleToolbar(controller: _controller, config: const QuillSimpleToolbarConfig()),
          ),
          Container(
            padding: const EdgeInsets.only(top: 80, left: 30, right: 30),
            child: Column(
              children: [
                Expanded(
                  child: MyEditor(
                    controller: _controller,
                    scrollController: _scrollController,
                    configurations: QuillEditorConfig(
                      placeholder: 'Write something',
                      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                      scrollable: true,
                      expands: true,
                    ),
                    focusNode: _focusNode,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
