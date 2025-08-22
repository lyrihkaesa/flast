void logStep(String message, {int indent = 2, String prefix = r'$ '}) {
  final spaces = ' ' * indent;
  print('$spaces$prefix$message');
}

/// Print a message inside a terminal-safe box with optional header
/// Margin = spasi di luar kotak
/// Padding = spasi di dalam kotak
/// Header = judul dengan garis separator yang nyambung
void printBoxMessage(
  String message, {
  String? header,
  int minWidth = 60,
  int marginLeft = 0,
  int marginRight = 0,
  int marginTop = 0,
  int marginBottom = 0,
  int paddingLeft = 1,
  int paddingRight = 1,
  int paddingTop = 0,
  int paddingBottom = 0,
}) {
  final hLine = '─';
  final vLine = '│';
  final cornerTL = '┌';
  final cornerTR = '┐';
  final cornerBL = '└';
  final cornerBR = '┘';
  final crossLeft = '├';
  final crossRight = '┤';

  final lines = <String>[];
  for (var line in message.split('\n')) {
    lines.addAll(_splitLongLine(line, minWidth - paddingLeft - paddingRight));
  }

  int contentWidth = lines.map((l) => l.length).fold(minWidth, (a, b) => a > b ? a : b);
  if (header != null && header.length > contentWidth) contentWidth = header.length;
  final width = contentWidth + paddingLeft + paddingRight;

  final marginLeftSpace = ' ' * marginLeft;
  final marginRightSpace = ' ' * marginRight;
  final padLeftSpace = ' ' * paddingLeft;
  final padRightSpace = ' ' * paddingRight;

  // Top margin
  for (int i = 0; i < marginTop; i++) print('');

  // Top border
  print('$marginLeftSpace$cornerTL${hLine * width}$cornerTR$marginRightSpace');

  // Header
  if (header != null) {
    final paddedHeader = header.padRight(contentWidth);
    print('$marginLeftSpace$vLine$padLeftSpace$paddedHeader$padRightSpace$vLine$marginRightSpace');
    // Header separator
    print('$marginLeftSpace$crossLeft${hLine * width}$crossRight$marginRightSpace');
  }

  // Top padding
  for (int i = 0; i < paddingTop; i++) {
    print('$marginLeftSpace$vLine${' ' * width}$vLine$marginRightSpace');
  }

  // Content
  for (var line in lines) {
    final paddedLine = line.padRight(contentWidth);
    print('$marginLeftSpace$vLine$padLeftSpace$paddedLine$padRightSpace$vLine$marginRightSpace');
  }

  // Bottom padding
  for (int i = 0; i < paddingBottom; i++) {
    print('$marginLeftSpace$vLine${' ' * width}$vLine$marginRightSpace');
  }

  // Bottom border
  print('$marginLeftSpace$cornerBL${hLine * width}$cornerBR$marginRightSpace');

  // Bottom margin
  for (int i = 0; i < marginBottom; i++) print('');
}

/// Helper: split line panjang menjadi beberapa baris agar muat
List<String> _splitLongLine(String line, int maxWidth) {
  final result = <String>[];
  var current = line;
  while (current.length > maxWidth) {
    result.add(current.substring(0, maxWidth));
    current = current.substring(maxWidth);
  }
  if (current.isNotEmpty) result.add(current);
  return result;
}
