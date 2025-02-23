import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class MyEditor extends StatefulWidget {
  final QuillController _controller;

  final void Function(Document document) onChange;
  final ScrollController _scrollController;
  final FocusNode _focusNode;
  final QuillEditorConfig configurations;
  const MyEditor({
    super.key,
    required QuillController controller,
    required ScrollController scrollController,
    required FocusNode focusNode,
    required this.onChange,
    required this.configurations,
  }) : _controller = controller,
       _scrollController = scrollController,
       _focusNode = focusNode;

  @override
  State<MyEditor> createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  @override
  void initState() {
    widget._controller.addListener(_onChangeUpdate);
    super.initState();
  }

  @override
  void dispose() {
    widget._controller.removeListener(_onChangeUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      controller: widget._controller,
      scrollController: widget._scrollController,
      focusNode: widget._focusNode,
      config: widget.configurations,
    );
  }

  void _onChangeUpdate() {
    widget.onChange.call(widget._controller.document);
  }
}
