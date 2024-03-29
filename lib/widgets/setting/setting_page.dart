import 'package:flutter/material.dart';
import 'package:mizar_music_app/widgets/setting/cache/cache_page.dart';

import '../../common/index.dart';
// import 'skin/skin_page.dart';

class PersonSettingPage extends StatefulWidget {
  const PersonSettingPage({super.key, required this.title});

  final String title;

  @override
  State<PersonSettingPage> createState() => _PersonSettingPageState();
}

class _PersonSettingPageState extends State<PersonSettingPage> {
  Widget _buildMainView() {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // mizar music intro view
        _buildMizarMusicIntroView(),
        // every item setting info
        _buildSettingItemInfoView(
          title: "存储配置",
          icon: AppIcons.storehouse,
          onTap: () => {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CachePage())),
          },
        ),
        _buildSettingItemInfoView(
          title: "音乐分组",
          icon: Icons.queue_music_rounded,
          onTap: () {
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CachePage())),
            toast("更多精彩，敬请期待!");
          },
        ),
        // _buildSettingItemInfoView(
        //   title: "皮肤切换",
        //   icon: AppIcons.skin,
        //   onTap: () => {
        //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SkinPage())),
        //   },
        // ),
        // _buildSettingItemInfoView(
        //   title: "缓存管理",
        //   icon: AppIcons.cache,
        //   onTap: () => {},
        //   suffixWidget: const Text(
        //     "125MB",
        //     style: TextStyle(color: AppColors.textColor),
        //   ),
        // ),
        // _buildSettingItemInfoView(
        //   title: "检查更新",
        //   icon: AppIcons.version,
        //   onTap: () => {},
        //   suffixWidget: const Text(
        //     "1.0.0.0",
        //     style: TextStyle(color: AppColors.textColor),
        //   ),
        // ),
      ]),
    );
  }

  Widget _buildSettingItemInfoView({required String title, required IconData icon, Function()? onTap, Widget? suffixWidget}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 68,
        padding: const EdgeInsets.all(AppSizes.kPaddingSize),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 5, color: Colors.grey.shade100))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Icon(icon, size: 20),
          AppSizes.boxW10,
          Text(title, style: const TextStyle(color: AppColors.titleColor)),
          const Spacer(),
          suffixWidget ?? const SizedBox.shrink(),
          onTap != null ? const Icon(Icons.arrow_right, color: AppColors.textColor) : const SizedBox.shrink(),
        ]),
      ),
    );
  }

  Widget _buildMizarMusicIntroView() {
    return Card(
      margin: const EdgeInsets.all(AppSizes.kPaddingSize),
      color: AppColors.middleColor,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.kPaddingSize),
        height: 120,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // mizar logo
          CircleAvatar(
            backgroundColor: AppColors.backgroundColor,
            radius: 45,
            child: Image.asset(AppAssets.logo),
          ),
          AppSizes.boxW20,
          // intro for music
          Padding(
            padding: const EdgeInsets.only(top: AppSizes.kPaddingSize),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 110 - (4 * AppSizes.kPaddingSize),
              child: const Text.rich(
                TextSpan(children: [
                  TextSpan(text: "开阳音乐", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextSpan(text: "\r\n开阳(大熊座ζ)是大熊座的一颗恒星", style: TextStyle(fontSize: 12)),
                  TextSpan(text: "\r\n位在北斗的斗柄尾端第二颗星, 是北斗七星之一", style: TextStyle(fontSize: 12)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainView();
  }
}
