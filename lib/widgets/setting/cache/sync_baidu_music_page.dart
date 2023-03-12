import 'package:flutter/material.dart';
import 'package:mizar_music_app/api/index.dart';
import 'package:mizar_music_app/common/index.dart';
import 'package:mizar_music_app/entity/music_info.dart';
import 'package:mizar_music_app/extension/int_extension.dart';
import 'package:mizar_music_app/utils/index.dart';

class SyncBaiduMusicPage extends StatefulWidget {
  const SyncBaiduMusicPage({super.key});

  @override
  State<SyncBaiduMusicPage> createState() => _SyncBaiduMusicPageState();
}

class _SyncBaiduMusicPageState extends State<SyncBaiduMusicPage> {
  String title = "同步中...";
  List? musicList;

  @override
  void initState() {
    super.initState();
    _fetchBaiduMusicList();
  }

  _fetchBaiduMusicList() async {
    // 获取百度token
    String accessToken = await BaiduHelper.accessToken();
    Map<String, dynamic> res = await BaiduApi.getMusicList(accessToken);
    LoggerHelper.d(res);
    if (res['errno'] == 0) {
      List list = res['list'] ?? [];
      if (list.isEmpty) {
        setState(() {
          title = "文件夹内为空";
        });
      } else {
        List insertDatas = [];
        for (var element in list) {
          insertDatas.add(MusicInfoEntity.fromMap(element));
        }
        await TableHelper.deleteAll("t_music_list");
        await TableHelper.batchInsert("t_music_list", insertDatas);
        setState(() {
          title = "同步成功";
          musicList = insertDatas;
        });
      }
    } else {
      setState(() {
        title = "抓取数据失败";
      });
      toast("抓取数据失败，请返回上一页稍后重试");
    }
  }

  Widget _buildMainView() {
    return Scaffold(
      appBar: refAppBar(context: context, title: title),
      body: musicList != null
          ? ListView.custom(
              childrenDelegate: SliverChildBuilderDelegate((context, index) {
                MusicInfoEntity mi = musicList![index];
                return Container(
                  width: double.infinity,
                  height: 54 + (2 * AppSizes.kPaddingSize),
                  padding: const EdgeInsets.all(AppSizes.kPaddingSize),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundColor,
                    border: Border(bottom: BorderSide(width: 5, color: AppColors.middleColor)),
                  ),
                  child: Column(children: [
                    SizedBox(
                      width: double.infinity,
                      height: 24,
                      child: Text(mi.musicName as String, style: const TextStyle(fontSize: 16)),
                    ),
                    Expanded(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text("${mi.author}\t"),
                        Text(
                          "${(mi.size! / 1024 / 1024).toStringAsFixed(1)}MB",
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          "同步时间: ${mi.createTime!.toYYYYMMDDHHmmss()}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ]),
                    ),
                  ]),
                );
              }, childCount: musicList!.length),
            )
          : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainView();
  }
}
