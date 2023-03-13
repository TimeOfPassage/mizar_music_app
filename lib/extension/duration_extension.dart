extension DurationExtension on Duration {
  String toMinuteSeconds() {
    int minutes = (inSeconds / 60).floor();
    int seconds = inSeconds % 60;
    String sec = seconds < 10 ? "0$seconds" : seconds.toString();
    if (minutes <= 0) {
      return "00:$sec";
    }
    if (minutes < 10) {
      return "0$minutes:$sec";
    }
    return "$minutes:$sec";
  }
}
