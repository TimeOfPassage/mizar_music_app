extension IntExtension on int {
  String toDay() {
    int minutes = (this / 60).floor(); // this = 25761735, minutes = 429362
    if (minutes <= 0) {
      return "$this秒";
    }
    int remainSeconds = this % 60; // remainSeconds = 60
    int hours = (minutes / 60).floor(); // hours = 7156
    if (hours <= 0) {
      if (remainSeconds == 0) {
        return "$minutes分钟";
      }
      return "$minutes分钟$remainSeconds秒";
    }
    int remainMinutes = hours % 60;
    int days = (hours / 24).floor();
    if (days <= 0) {
      if (remainSeconds == 0) {
        return "$hours小时$remainMinutes分钟";
      }
      if (remainMinutes == 0) {
        return "$hours小时$remainSeconds秒";
      }
      return "$hours小时$remainMinutes分钟$remainSeconds秒";
    }
    int remainHours = days % 24;
    if (remainSeconds == 0) {
      return "$days天$remainHours小时$remainMinutes分钟";
    }
    if (remainMinutes == 0) {
      return "$days天$remainHours小时$remainSeconds秒";
    }
    if (remainHours == 0) {
      return "$days天$remainMinutes分钟$remainSeconds秒";
    }
    return "$days天$remainHours小时$remainMinutes分钟$remainSeconds秒";
  }
}
