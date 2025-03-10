import 'package:xml/xml.dart';

import '../../default/xml_defaults.dart';

class RelationShip {
  RelationShip({
    required this.rId,
    required this.target,
    required this.type,
    this.mode,
  })  : assert(rId.trim().isNotEmpty, 'rId cannot be empty'),
        assert(target.trim().isNotEmpty, 'target cannot be empty'),
        assert(type.trim().isNotEmpty, 'type cannot be empty');

  final String rId;
  final String target;
  final String type;
  final String? mode;

  @override
  String toString() {
    return 'RelationShip(rId: $rId, type: $type, target: $target)';
  }

  String toXmlString({String leftIndent = ''}) {
    return '$leftIndent<RelationShip Id="$rId" Type="$type" Target="$target" ${mode == null ? '' : 'TargetMode="$mode" '}/>';
  }

  XmlElement toXml() {
    return XmlDefaults.relation(
      rId: rId,
      type: type,
      target: target,
      targetMode: mode,
    );
  }
}

typedef RelationShipsBuilder = List<RelationShip> Function(int lastId);
