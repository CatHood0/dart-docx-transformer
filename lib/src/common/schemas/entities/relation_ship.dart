class RelationShip {
  RelationShip({
    required this.rId,
    required this.target,
    required this.type,
  })  : assert(rId.trim().isNotEmpty, 'rId cannot be empty'),
        assert(target.trim().isNotEmpty, 'target cannot be empty'),
        assert(type.trim().isNotEmpty, 'type cannot be empty');

  final String rId;
  final String target;
  final String type;

  @override
  String toString() {
    return 'RelationShip(rId: $rId, type: $type, target: $target)';
  }

  String toXmlString({String leftIndent = ''}) {
    return '$leftIndent<RelationShip Id="$rId" Type="$type" Target="$target" />';
  }
}

typedef RelationShipsBuilder = List<RelationShip> Function(int lastId);
