import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mizar_music_app/common/index.dart';

/// 自定义appbar
AppBar refAppBar({
  required String title,
  Color? backgroundColor,
}) {
  return AppBar(
    backgroundColor: backgroundColor ?? AppColors.backgroundColor,
    elevation: 0,
    title: Text(title, style: const TextStyle(color: AppColors.titleColor)),
  );
}

/// 全局toast
toast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: AppColors.textColor,
    textColor: AppColors.backgroundColor,
    fontSize: 16.0,
  );
}
