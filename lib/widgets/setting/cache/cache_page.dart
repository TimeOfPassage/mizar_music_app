import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mizar_music_app/api/index.dart';
import 'package:mizar_music_app/extension/int_extension.dart';
import 'package:mizar_music_app/utils/index.dart';
import 'package:mizar_music_app/widgets/setting/cache/sync_baidu_music_page.dart';
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
  Map<String, dynamic>? baiduUserInfo;
  Map<String, dynamic>? baiduCapicity;
  bool isRepeated = false;
  bool isLoading = false;

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
          // int expiresIn = int.parse(res['expires_in'].toString());
          // int lastStoreTime = int.parse(res['store_time'].toString());
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
          });
        } else {
          String insertSql = 'INSERT INTO "baidu_config" ( "access_token", "expires_in", "session_secret", "session_key", "scope", "store_time" ) VALUES ( ?, ?, ?, ?, ?, ?);';
          await TableHelper.insert(insertSql, [bc.accessToken, bc.expiresIn, bc.sessionKey, bc.sessionSecret, bc.scope, now]);
          toast("百度配置已写入，你可以正常使用了。祝您使用愉快！");
          setState(() {
            isRepeated = true;
          });
        }
        // 清空剪切板
        Clipboard.setData(const ClipboardData());
        // 抓去数据
        await _fetchBaiduConfigInfo();
      }
    }
  }

  _fetchBaiduConfigInfo() async {
    setState(() {
      isLoading = true;
    });
    String existSql = "select * from baidu_config";
    List<Map<dynamic, dynamic>> results = await TableHelper.query(existSql);
    if (results.isNotEmpty) {
      Map<dynamic, dynamic> res = results[0];
      int expiresIn = res['expires_in'];
      int storeTime = res['store_time'];
      int now = (DateTime.now().millisecondsSinceEpoch / 1000).round();
      LoggerHelper.d(storeTime + expiresIn - now);
      var user = await BaiduApi.getUserInfo(res['access_token']);
      var capicity = await BaiduApi.getNetdiskCapicity(res['access_token']);
      setState(() {
        nextUpdateTokenTime = (storeTime + expiresIn - now).toDateShow();
        if (user['errno'] == 0) {
          baiduUserInfo = user;
        }
        if (capicity['errno'] == 0) {
          baiduCapicity = capicity;
        }
        isLoading = false;
      });
    }
  }

  Widget _buildMainView() {
    return Scaffold(
      appBar: refAppBar(context: context, title: "存储配置"),
      body: isLoading
          ? Center(child: LoadingAnimationWidget.dotsTriangle(color: AppColors.brandColor, size: 60))
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                suffixWidget: nextUpdateTokenTime != null
                    ? Text(
                        "$nextUpdateTokenTime",
                        style: const TextStyle(fontSize: 12),
                      )
                    : const Text("去授权"),
                showUserInfo: baiduUserInfo != null,
              ),
            ]),
    );
  }

  Widget _buildSettingItemInfoView({required String title, required IconData icon, Function()? onTap, Widget? suffixWidget, bool showUserInfo = false}) {
    return Column(
      children: [
        // 条目项
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 68,
            padding: const EdgeInsets.all(AppSizes.kPaddingSize),
            decoration: !showUserInfo ? BoxDecoration(border: Border(bottom: BorderSide(width: 5, color: Colors.grey.shade100))) : null,
            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Icon(icon, size: 20),
              AppSizes.boxW10,
              Text(title, style: const TextStyle(color: AppColors.titleColor)),
              const Spacer(),
              suffixWidget ?? const SizedBox.shrink(),
              onTap != null ? const Icon(Icons.arrow_right, color: AppColors.textColor) : const SizedBox.shrink(),
            ]),
          ),
        ),
        // 获取配置信息
        showUserInfo
            ? Container(
                decoration: showUserInfo
                    ? BoxDecoration(
                        border: Border(bottom: BorderSide(width: 5, color: Colors.grey.shade100)),
                        color: AppColors.backgroundColor,
                      )
                    : null,
                child: Row(children: [
                  // mizar logo
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.kPaddingSize),
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(90),
                        border: Border.all(width: 1, color: AppColors.middleColor),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(baiduUserInfo!['avatar_url']),
                    ),
                  ),
                  AppSizes.boxW20,
                  // intro for music
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 170 - (4 * AppSizes.kPaddingSize),
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(text: "百度账号: ${baiduUserInfo!['baidu_name']}\n", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const TextSpan(),
                        TextSpan(text: "昵称: ${baiduUserInfo!['netdisk_name']}\n", style: const TextStyle(fontSize: 14)),
                        const TextSpan(),
                        TextSpan(
                            text: "容量: ${(baiduCapicity!['used'] / 1024 / 1024 / 1024).floor()}G/${(baiduCapicity!['total'] / 1024 / 1024 / 1024).floor()}G", style: const TextStyle(fontSize: 12)),
                      ]),
                    ),
                  ),
                  // 同步百度数据
                  SizedBox(
                    width: 60,
                    child: IconButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("提示"),
                              content: const Text("确定要同步百度云目录(mizar_music)下数据么? 此操作可能产生的流量费用和该目录下文件总大小相关, 故最好在wifi下操作."),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text("取消"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: const Text("开始同步"),
                                  onPressed: () async {
                                    Navigator.of(context).pop(true);
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SyncBaiduMusicPage()));
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.sync_alt),
                    ),
                  ),
                ]),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainView();
  }
}
