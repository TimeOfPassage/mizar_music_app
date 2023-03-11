import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mizar_music_app/extension/color_extension.dart';
import 'package:mizar_music_app/widgets/tabbar/app_tabbar.dart';

import 'common/index.dart';
import 'utils/index.dart';

void main() {
  // 确保初始化
  WidgetsFlutterBinding.ensureInitialized();
  //滚动性能优化 1.22.0
  GestureBinding.instance.resamplingEnabled = true;
  // init logger
  LoggerHelper().initLogger();
  // 运行主App
  runApp(const MizarMusicApp());
  //设置Android头部的导航栏透明
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MizarMusicApp extends StatelessWidget {
  const MizarMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mizar Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: Colors.transparent, // 设置点击无水波
        highlightColor: Colors.transparent, // 设置点击无水波
        primarySwatch: AppColors.brandColor.toMaterialColor(),
        appBarTheme: const AppBarTheme(titleTextStyle: TextStyle(color: AppColors.textColor, fontSize: 24)),
      ),
      home: const AppTabbarWidget(),
    );
  }
}
