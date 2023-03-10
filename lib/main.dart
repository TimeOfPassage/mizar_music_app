import 'package:flutter/material.dart';
import 'package:mizar_music_app/extension/color_extension.dart';
import 'package:mizar_music_app/widgets/tabbar/app_tabbar.dart';

import 'common/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mizar Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: Colors.transparent, // 设置点击无水波
        highlightColor: Colors.transparent,
        primarySwatch: AppColors.brandColor.toMaterialColor(),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: AppColors.textColor,
            fontSize: 24,
          ),
        ),
      ),
      home: const AppTabbarWidget(),
    );
  }
}
