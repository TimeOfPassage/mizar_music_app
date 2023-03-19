import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:logger/logger.dart';
import 'package:mizar_music_app/extension/color_extension.dart';
import 'package:mizar_music_app/widgets/tabbar/app_tabbar.dart';

import 'common/index.dart';
import 'utils/index.dart';

void main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.mizar.music.channel.audio',
    androidNotificationChannelName: 'AudioBackgrounPlay',
    androidNotificationOngoing: true,
  );
  await _init();
  runApp(const MizarMusicApp());
  //设置Android头部的导航栏透明
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

Future _init() async {
  // init logger
  LoggerHelper().initLogger(level: Level.info);
  // init database
  await TableHelper().init();
  await TableHelper.open();
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
