String generateId({required String type, required String prefix}) {
  DateTime customEpoch = DateTime(2025, 1, 1, 0, 0, 0, 0, 0);
  DateTime now = DateTime.now();
  Duration difference = now.difference(customEpoch);
  return type + prefix.substring(0, 2) + difference.inMilliseconds.toString();
}
