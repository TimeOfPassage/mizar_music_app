import 'package:flutter/material.dart';
import 'package:mizar_music_app/common/index.dart';

import '../index.dart';

class AppTabbarWidget extends StatefulWidget {
  const AppTabbarWidget({super.key});

  @override
  State<AppTabbarWidget> createState() => _AppTabbarWidgetState();
}

class _AppTabbarWidgetState extends State<AppTabbarWidget> {
  late PageController _controller;
  int _currentIndex = 1;

  // tabbar list
  List<Widget> bottomBarList = const [
    HomePage(),
    PersonSettingPage(title: "个性化设置"),
  ];
  // tabbar list label
  List bottomBarConfigs = [
    {"icon": AppIcons.homeMusic, "label": '音乐'},
    {"icon": AppIcons.personSetting, "label": '设置'}
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildMainView() {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: AppColors.backgroundColor,
      //   title: Text(bottomBarConfigs[_currentIndex]['label'], style: const TextStyle(color: AppColors.titleColor)),
      //   elevation: 0,
      // ),
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(), // 禁止左右滚动
        children: bottomBarList,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        onTap: (index) {
          _controller.jumpToPage(index);
          setState(() {
            _currentIndex = index;
          });
        },
        currentIndex: _currentIndex,
        selectedFontSize: 12,
        items: bottomBarConfigs.map((e) => _buildBottomBarItem(e['icon'], e['label'])).toList(),
      ),
    );
  }

  /// 构建底部bar item
  BottomNavigationBarItem _buildBottomBarItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(icon, color: AppColors.brandColor),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainView();
  }
}
