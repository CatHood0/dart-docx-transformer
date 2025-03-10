import 'package:xml/xml.dart';

import '../../constants.dart';
import '../schemas/common_node_keys/xml_keys.dart';

class DocDefaultParagraphStyles {
  DocDefaultParagraphStyles({
    double spacing = 1.0,
    this.alignment = 'left',
    this.header,
  })  : assert(
          spacing > 200 || (spacing > 0 && spacing < 5.0),
          'spacing must be into Word standard or into the range of 1.0 to 5.0',
        ),
        assert(
          alignment == 'left' ||
              alignment == 'right' ||
              alignment == 'center' ||
              (alignment == 'both' || alignment == 'justify'),
          'alignment only supported: left, right, center, justify and both',
        ) {
    this.spacing = spacing > 200 ? spacing : spacing * kDefaultSpacing1;
  }

  DocDefaultParagraphStyles.base()
      : spacing = 1.0 * kDefaultSpacing1,
        alignment = 'left',
        header = null;

  late final double spacing;
  late final String alignment;
  late final int? header;

  XmlElement toNode() {
    return XmlElement.tag(
      xmlParagraphBlockAttrsNode,
      children: <XmlNode>[],
      isSelfClosing: false,
    );
  }
}
