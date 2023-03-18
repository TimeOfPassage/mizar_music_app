extension DurationExtension on Duration {
  String toHMS() {
    // return toString().split('.').first.padLeft(8, "0");
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    return "${inHours > 0 ? '$inHours:':''}$twoDigitMinutes:$twoDigitSeconds";
  }
}
