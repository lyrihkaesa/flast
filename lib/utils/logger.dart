void logStep(String message, {int indent = 2, String prefix = r'$ '}) {
  final spaces = ' ' * indent;
  print('$spaces$prefix$message');
}
