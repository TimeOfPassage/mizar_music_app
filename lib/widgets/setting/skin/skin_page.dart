import 'package:flutter/material.dart';
import 'package:mizar_music_app/common/index.dart';

/// 皮肤切换页面
class SkinPage extends StatefulWidget {
  const SkinPage({super.key});

  @override
  State<SkinPage> createState() => _SkinPageState();
}

class _SkinPageState extends State<SkinPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text("皮肤切换", style: TextStyle(color: AppColors.titleColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("确定"),
          )
        ],
      ),
      body: const Text("hello"),
    );
  }
}
