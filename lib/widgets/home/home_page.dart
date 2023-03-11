import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// home page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildMainView() {
    return TextButton(
      onPressed: () async {
        ClipboardData? text = await Clipboard.getData(Clipboard.kTextPlain);
        // LoggerHelper.i(text?.text.toString());
        debugPrint(text?.text.toString() ?? "empty data");
      },
      child: const Text("获取剪贴板内容"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainView();
  }
}
