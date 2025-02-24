bool isValidColor(String? s) {
  if (s == null || s.trim().isEmpty) return false;
  switch (s) {
    case 'transparent':
    case 'black':
    case 'black12':
    case 'black26':
    case 'black38':
    case 'black45':
    case 'black54':
    case 'black87':
    case 'white':
    case 'white10':
    case 'white12':
    case 'white24':
    case 'white30':
    case 'white38':
    case 'white54':
    case 'white60':
    case 'white70':
    case 'red':
    case 'redAccent':
    case 'amber':
    case 'amberAccent':
    case 'yellow':
    case 'yellowAccent':
    case 'teal':
    case 'tealAccent':
    case 'purple':
    case 'purpleAccent':
    case 'pink':
    case 'orange':
    case 'orangeAccent':
    case 'deepOrange':
    case 'deepOrangeAccent':
    case 'indigo':
    case 'indigoAccent':
    case 'lime':
    case 'limeAccent':
    case 'grey':
    case 'blueGrey':
    case 'green':
    case 'greenAccent':
    case 'lightGreen':
    case 'lightGreenAccent':
    case 'blue':
    case 'blueAccent':
    case 'lightBlue':
    case 'lightBlueAccent':
    case 'cyan':
    case 'cyanAccent':
    case 'brown':
      return true;
  }

  if (s.startsWith('rgba') || !s.startsWith('#') || s.startsWith('inherit') || s.startsWith('000000')) {
    return false;
  }
  return true;
}
