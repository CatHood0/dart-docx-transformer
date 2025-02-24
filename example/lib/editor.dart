import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class MyEditor extends StatefulWidget {
  final QuillController _controller;

  final ScrollController _scrollController;
  final FocusNode _focusNode;
  final QuillEditorConfig configurations;
  const MyEditor({
    super.key,
    required QuillController controller,
    required ScrollController scrollController,
    required FocusNode focusNode,
    required this.configurations,
  }) : _controller = controller,
       _scrollController = scrollController,
       _focusNode = focusNode;

  @override
  State<MyEditor> createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      controller: widget._controller,
      scrollController: widget._scrollController,
      focusNode: widget._focusNode,
      config: widget.configurations,
    );
  }
}
