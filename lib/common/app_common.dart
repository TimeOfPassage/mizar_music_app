import 'package:flutter/material.dart';
import 'package:mizar_music_app/common/index.dart';

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
