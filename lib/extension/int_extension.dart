extension IntExtension on int {
  String toDateShow() {
    int minutes = (this / 60).floor(); // this = 2576173, minutes = 42936
    if (minutes <= 0) {
      // 只到秒级
      return "$this秒";
    }
    int hours = (minutes / 60).floor(); // hours = 715
    int remainSeconds = this % 60;
    if (hours <= 0) {
      // 只到分钟级
      if (remainSeconds == 0) {
        return "$minutes分";
      }
      return "$minutes分$remainSeconds秒";
    }
    int days = (hours / 24).floor(); // days = 29
    int remainMinutes = minutes % 60;
    if (days <= 0) {
      // 只到小时级
      if (remainSeconds == 0) {
        return "$hours小时$remainMinutes分";
      }
      if (remainMinutes == 0) {
        return "$hours小时$remainSeconds秒";
      }
      return "$hours小时$remainMinutes分$remainSeconds秒";
    }
    // 换算成天后，剩余小时数
    int remainHours = hours % 24;
    if (remainSeconds == 0) {
      if (remainMinutes == 0) {
        if (remainHours == 0) {
          return "$days天";
        }
        return "$days天$remainHours小时";
      }
      return "$days天$remainHours小时$remainMinutes分";
    }
    if (remainMinutes == 0) {
      if (remainHours == 0) {
        return "$days天$remainSeconds秒";
      }
      return "$days天$remainHours小时$remainSeconds秒";
    }
    if (remainHours == 0) {
      if (remainMinutes == 0) {
        return "$days天$remainSeconds秒";
      }
      return "$days天$remainMinutes分$remainSeconds秒";
    }
    return "$days天$remainHours小时$remainMinutes分$remainSeconds秒";
  }
}
