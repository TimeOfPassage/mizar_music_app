import 'package:flutter/material.dart';

import '../../../common/index.dart';

class CachePage extends StatefulWidget {
  const CachePage({super.key});

  @override
  State<CachePage> createState() => _CachePageState();
}

class _CachePageState extends State<CachePage> {
  Widget _buildMainView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text("存储配置", style: TextStyle(color: AppColors.titleColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // every item setting info
        _buildSettingItemInfoView(
          title: "码云(Gitee)配置",
          icon: AppIcons.gitee,
          onTap: () => {
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CachePage())),
          },
        ),
        _buildSettingItemInfoView(
          title: "百度云配置",
          icon: AppIcons.baidu,
          onTap: () => {
            // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CachePage())),
          },
        ),
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

  @override
  Widget build(BuildContext context) {
    return _buildMainView();
  }
}
