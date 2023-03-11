import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mizar_music_app/extension/int_extension.dart';
import 'package:mizar_music_app/utils/index.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/index.dart';
import '../../../entity/baidu_config.dart';

class CachePage extends StatefulWidget {
  const CachePage({super.key});

  @override
  State<CachePage> createState() => _CachePageState();
}

class _CachePageState extends State<CachePage> with WidgetsBindingObserver {
  String? nextUpdateTokenTime;
  bool isRepeated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // fetch config info
    _fetchBaiduConfigInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // 读取剪贴板数据
      ClipboardData? clipboard = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboard == null) {
        return;
      }
      if (isRepeated) {
        return;
      }
      // https://openapi.baidu.com/oauth/2.0/login_success#expires_in=2592000&access_token=123.e3d84b8ea407f68cb2c9488254e9b26a.YB9S4Ba5ZApAc-LMuXaEaH8tq-yH00Yr6rbCjKx.l9USDQ&session_secret=&session_key=&scope=basic+netdisk
      String url = clipboard.text.toString();
      if (url.startsWith("https://openapi.baidu.com/oauth/2.0/login_success")) {
        // var uri = Uri.parse(url);
        List<String> authInfos = url.split("#")[1].toString().split("&");
        var bc = BaiduConfigEntity();
        for (var e in authInfos) {
          List<String> arr = e.split("=");
          if ("expires_in" == arr[0].trim()) {
            bc.expiresIn = int.parse(arr[1]);
          }
          if ("access_token" == arr[0].trim()) {
            bc.accessToken = arr[1];
          }
          if ("session_secret" == arr[0].trim()) {
            bc.sessionSecret = arr[1];
          }
          if ("session_key" == arr[0].trim()) {
            bc.sessionKey = arr[1];
          }
          if ("scope" == arr[0].trim()) {
            bc.scope = arr[1];
          }
        }
        int now = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
        String existSql = "select * from baidu_config";
        List<Map<dynamic, dynamic>> results = await TableHelper.query(existSql);
        if (results.isNotEmpty) {
          Map<dynamic, dynamic> res = results[0];
          // int lastStoreTime = int.parse(res['store_time'].toString());
          int expiresIn = int.parse(res['expires_in'].toString());
          // if (now - lastStoreTime > expiresIn) {
          //   String updateSql = 'UPDATE "baidu_config" SET "access_token" = ?, "expires_in" = ?, "session_secret" = ?, "session_key" = ?, "scope" = ?, "store_time" = ? WHERE "id" = ?;';
          //   await TableHelper.update(updateSql, [bc.accessToken, bc.expiresIn, bc.sessionKey, bc.sessionSecret, bc.scope, now, res['id']]);
          //   toast("百度配置已更新！");
          // } else {
          //   toast("百度配置已存在");
          // }
          String updateSql = 'UPDATE "baidu_config" SET "access_token" = ?, "expires_in" = ?, "session_secret" = ?, "session_key" = ?, "scope" = ?, "store_time" = ? WHERE "id" = ?;';
          await TableHelper.update(updateSql, [bc.accessToken, bc.expiresIn, bc.sessionKey, bc.sessionSecret, bc.scope, now, res['id']]);
          toast("百度配置已更新！");
          setState(() {
            isRepeated = true;
            nextUpdateTokenTime = (now + expiresIn - now).toDay();
          });
        } else {
          String insertSql = 'INSERT INTO "baidu_config" ( "access_token", "expires_in", "session_secret", "session_key", "scope", "store_time" ) VALUES ( ?, ?, ?, ?, ?, ?);';
          await TableHelper.insert(insertSql, [bc.accessToken, bc.expiresIn, bc.sessionKey, bc.sessionSecret, bc.scope, now]);
          toast("百度配置已写入，你可以正常使用了。祝您使用愉快！");
          setState(() {
            isRepeated = true;
            int expiresIn = bc.expiresIn!;
            nextUpdateTokenTime = (now + expiresIn - now).toDay();
          });
        }
      }
    }
  }

  _fetchBaiduConfigInfo() async {
    await TableHelper.open();
    String existSql = "select * from baidu_config";
    List<Map<dynamic, dynamic>> results = await TableHelper.query(existSql);
    if (results.isNotEmpty) {
      Map<dynamic, dynamic> res = results[0];
      int expiresIn = res['expires_in'];
      int storeTime = res['store_time'];
      int now = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      LoggerHelper.d(storeTime + expiresIn - now);
      setState(() {
        nextUpdateTokenTime = (storeTime + expiresIn - now).toDay();
      });
    }
  }

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
          onTap: () async {
            bool isOpenUrlSuccess = await launchUrl(Uri.parse(kBaiduAuthorizationUrl), mode: LaunchMode.externalApplication);
            if (!isOpenUrlSuccess) {
              await launchUrl(Uri.parse(kBaiduAuthorizationUrl), mode: LaunchMode.externalApplication);
            }
          },
          suffixWidget: nextUpdateTokenTime != null ? Text("授权可用时间: $nextUpdateTokenTime") : const Text("去授权"),
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
