import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/foundation.dart';
import 'package:quill_delta_docx_parser/src/common/keys/word_files_common.dart';
import 'package:quill_delta_docx_parser/src/common/keys/xml_keys.dart';
import 'package:quill_delta_docx_parser/src/parser/parser.dart';
import 'package:quill_delta_docx_parser/src/parser/parser_options.dart';
import 'package:quill_delta_docx_parser/src/util/predicate.dart';
import 'package:xml/xml.dart' as xml;

class DocxToDelta extends Parser<Uint8List, Delta?, DeltaParserOptions> {
  ZipDecoder? _zipDecoder;
  DocxToDelta({
    required super.data,
    required super.options,
  });

  @override
  Delta? build() {
    Delta delta = Delta();
    _zipDecoder ??= ZipDecoder();

    final archive = _zipDecoder!.decodeBytes(data);
    // we can get the styles of some paragraph directly
    // gettings first the
    //
    // We need to take in account, that are paragraph that implements the attribute
    // [rsId] or [rsIdDefault] that reference to a specific style into styles.xml
    // that applies different styles to that paragraph implicitely without passing them
    xml.XmlDocument? styles;
    Directory? media;
    xml.XmlDocument? document;

    // search the necessary files
    for (final file in archive) {
      if (file.isFile && file.name == stylesXmlFilePath) {
        final fileContent = utf8.decode(file.content);
        styles = xml.XmlDocument.parse(fileContent);
      }
      if (file.isDirectory && file.name == 'word/media') {
        final w = file.getContent();
        // TODO: implement media search?
      }
      if (file.isFile && file.name == documentFilePath) {
        final fileContent = utf8.decode(file.content);
        document = xml.XmlDocument.parse(fileContent);
      }
    }

    if (document == null) {
      throw StateError('$documentFilePath couldn\'t be founded into the File passed');
    }

    debugPrint(document.toXmlString(pretty: true, indent: ' ', level: 0));

    //TODO: remember sdt
    final paragraphNodes = document.findAllElements(xmlParagraphNode);

    for (final paragraph in paragraphNodes) {
      Map<String, dynamic> blockAttributes = {};
      Map<String, dynamic> inlineAttributes = {};
      // common parents nodes
      // level 1 priority
      final paragraphLevelAttributesNode = paragraph.getElement(xmlParagraphBlockAttrsNode);
      // <w:rPr> node could be into <w:pPr> since this last one correspond to the common attributes
      // applied to the entire paragraph (<w:p>)
      final commonInlineParagraphAttributes =
          paragraphLevelAttributesNode?.getElement(xmlParagraphInlineAttsrNode);
      // hyperlink works at level of <w:pPr> and <w:r>
      final hyperlinkNode = paragraph.getElement(xmlHyperlinkNode);
      // block attributes
      var listNode = paragraphLevelAttributesNode?.getElement(xmlListNode);
      var indentNode = paragraphLevelAttributesNode?.getElement(xmlTabNode);
      var alignNode = paragraphLevelAttributesNode?.getElement(xmlAlignmentNode);
      var spacingNode = paragraphLevelAttributesNode?.getElement(xmlSpacingNode);
      final textPartNodes = paragraph.findAllElements(xmlTextPartNode);
      // if the textPartNodes are empty we will need to ignore the paragraph
      // because it is only a new line
      if (textPartNodes.isEmpty) {
        //TODO: check if it has block attributes
        delta.insert('\n');
        continue;
      }
      // the nodes that contains every part of the text
      //
      // this is, because docx divides the content by preserved whitespaces
      // and styles attributes
      //
      // you can see this, like, separating text by inline attrs in delta
      //
      // [
      //  {"insert": "This is "},
      //  {"insert": "bold text", {"bold": true}},
      //  {"insert": " That works as an example"}
      // ]
      //
      for (final textPartNode in textPartNodes) {
        final inlineAttributesOfPart = textPartNode.getElement(xmlParagraphInlineAttsrNode);
        bool hasNoInlineAttrs = inlineAttributesOfPart == null && commonInlineParagraphAttributes == null;
        if (hasNoInlineAttrs) inlineAttributes.clear();
        // inline attribute section
        final fontFamilyNode = inlineAttributesOfPart?.getElement(xmlFontsNode) ??
            commonInlineParagraphAttributes?.getElement(xmlFontsNode);
        final familyAttr =
            fontFamilyNode?.getAttribute('asciiTheme') ?? fontFamilyNode?.getAttribute('hAnsiTheme');
        // check if we will accept this family
        if (familyAttr != null) {
          bool acceptFamily = true;
          if (fontFamilyNode != null) {
            acceptFamily = options.acceptFontValueWhen?.call(fontFamilyNode, familyAttr) ?? acceptFamily;
          }

          if (acceptFamily) {
            inlineAttributes['font'] = familyAttr;
          }
        }

        final fontSizeNode = inlineAttributesOfPart?.getElement(xmlFontsNode) ??
            commonInlineParagraphAttributes?.getElement(xmlFontsNode);
        final sizeAttr =
            fontSizeNode?.getAttribute(xmlSizeFontNode) ?? fontSizeNode?.getAttribute(xmlSizeCsFontNode);
        if (sizeAttr != null) {
          bool acceptSize = true;
          String size = sizeAttr;
          if (options.acceptSizeValueWhen != null) {
            acceptSize = options.acceptFontValueWhen?.call(fontSizeNode!, familyAttr!) ?? acceptSize;
          }
          if (acceptSize) {
            // transform if is passed
            if (options.transformSizeValueTo != null) {
              size = options.transformSizeValueTo!(sizeAttr);
            }
            if (size.isNotEmpty) {
              inlineAttributes['size'] = size;
            }
          }
        }

        final italicNode = (inlineAttributesOfPart?.getElement(xmlItalicNode) ??
                inlineAttributesOfPart?.getElement(xmlItalicNode)) ??
            (commonInlineParagraphAttributes?.getElement(xmlItalicNode) ??
                commonInlineParagraphAttributes?.getElement(xmlItalicNode));
        commonInlineParagraphAttributes?.getElement(xmlItalicNode);
        if (italicNode != null) {
          inlineAttributes['italic'] = true;
        }

        final boldNode = (inlineAttributesOfPart?.getElement(xmlBoldNode) ??
                inlineAttributesOfPart?.getElement(xmlBoldCsNode)) ??
            (commonInlineParagraphAttributes?.getElement(xmlBoldNode) ??
                commonInlineParagraphAttributes?.getElement(xmlBoldCsNode));
        if (boldNode != null) {
          inlineAttributes['italic'] = true;
        }

        final underlineNode = inlineAttributesOfPart?.getElement(xmlUnderlineNode) ??
            commonInlineParagraphAttributes?.getElement(xmlUnderlineNode);

        if (underlineNode != null) {
          inlineAttributes['underline'] = true;
        }

        //
        // the node that contains the text
        final textNode = textPartNode.getElement(xmlTextNode) ?? xml.XmlText('');
        var text = textNode.innerText;
        // when found <w:t xml:space="preserve"> means that this text is just a
        if (text.isEmpty) text = ' ';
        delta.insert(text, inlineAttributes.isEmpty ? null : inlineAttributes);
      }
      //TODO: divide inline and block attributes building to another function
      final isList = listNode != null;
      final containsIndent = indentNode != null;
      final containsAlignment = alignNode != null;
      final containsSpacing = spacingNode != null;
      if (isList) {
        final codeNum = listNode.getElement(xmlListTypeNode)!.getAttribute('w:val');
        final numberIndentLevel = listNode.getElement(xmlListIndentLevelNode)!.getAttribute('w:val');
        if (codeNum != null) {
          blockAttributes['list'] = codeNum == '2' ? 'bullet' : 'ordered';
        }
        if (numberIndentLevel != null) {
          final indent = int.tryParse(numberIndentLevel);
          if (indent != null && indent > 0) {
            blockAttributes['indent'] = indent;
          }
        }
      }
      if (blockAttributes.isNotEmpty) {
        delta.insert('\n', blockAttributes);
        continue;
      }
      delta.insert('\n');
    }

    return delta.isEmpty ? null : delta;
  }
}

class DeltaParserOptions extends ParserOptions {
  final double docxVersion;
  final Predicate<String>? acceptFontValueWhen;
  final Predicate<String>? acceptSizeValueWhen;

  /// a way to build a custom size from Word
  /// to a know value for Quill Delta
  ///
  /// like: "28" can be converted to "huge"
  final String Function(String)? transformSizeValueTo;

  /// This is a callback that decides if the operations
  /// founded at this point, contains misspelled attribute
  /// from &lt;w:proofErr/&gt;
  final PredicateMisspell? buildDeltaFromMisspelledOps;

  DeltaParserOptions({
    this.acceptFontValueWhen,
    this.acceptSizeValueWhen,
    this.transformSizeValueTo,
    this.buildDeltaFromMisspelledOps,
    this.docxVersion = WORD_VERSION_16,
  });
}

// supported versions
// ignore_for_file: constant_identifier_names
const double WORD_VERSION_16 = 1.6;
const double WORD_VERSION_18 = 1.8;
const double WORD_VERSION_19 = 1.9;
