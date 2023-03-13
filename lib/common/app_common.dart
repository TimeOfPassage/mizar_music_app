import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mizar_music_app/common/index.dart';

/// 自定义appbar
AppBar refAppBar({
  required BuildContext context,
  required String title,
  Color backgroundColor = AppColors.backgroundColor,
  Color backColor = Colors.black,
}) {
  return AppBar(
    backgroundColor: backgroundColor,
    elevation: 0,
    title: Text(title, style: const TextStyle(color: AppColors.titleColor)),
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios, color: backColor),
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
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
