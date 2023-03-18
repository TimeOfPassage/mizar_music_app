import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mizar_music_app/api/index.dart';
import 'package:mizar_music_app/common/index.dart';
import 'package:mizar_music_app/entity/music_info.dart';
import 'package:mizar_music_app/extension/int_extension.dart';
import 'package:mizar_music_app/utils/index.dart';
import 'package:path_provider/path_provider.dart';

class SyncBaiduMusicPage extends StatefulWidget {
  const SyncBaiduMusicPage({super.key});

  @override
  State<SyncBaiduMusicPage> createState() => _SyncBaiduMusicPageState();
}

class _SyncBaiduMusicPageState extends State<SyncBaiduMusicPage> {
  String title = "同步中...";
  List musicList = [];
  int downloadCount = 0;

  @override
  void initState() {
    super.initState();
    // 清除表里所有数据
    _clearMusicInfoFromDB().then((value) async {
      // 获取百度token
      String accessToken = await BaiduHelper.accessToken();
      // 循环获取所有待下载音乐信息
      _fetchBaiduMusicList(accessToken, start: 0, limit: 100);
    });
  }

  Future<bool> _clearMusicInfoFromDB() async {
    await TableHelper.deleteAll("t_music_list");
    return Future.value(true);
  }

  _fetchBaiduMusicList(String accessToken, {int start = 0, int limit = 100}) async {
    Map<String, dynamic> res = await BaiduApi.getMusicList(accessToken, start: start, limit: limit);
    LoggerHelper.d(res);
    if (res['errno'] == 0) {
      List list = res['list'] ?? [];
      if (list.isEmpty) {
        if (start == 0) {
          setState(() {
            title = "文件夹内为空";
          });
        } else {
          setState(() {
            title = "下载中(0/${musicList.length})";
          });
          _downloadFileToApplicationDir(accessToken);
        }
      } else {
        List<MusicInfoEntity> insertDatas = list.map((e) => MusicInfoEntity.fromMap(e)).toList();
        // fetch baidu hover url
        insertDatas = await _fetchBaiduPictureToFill(insertDatas);
        // 写入本地数据库
        await TableHelper.batchInsert("t_music_list", insertDatas);
        setState(() {
          if (musicList.isEmpty) {
            musicList = insertDatas;
          } else {
            musicList.addAll(insertDatas);
          }
        });
        // 抓取下一页
        _fetchBaiduMusicList(accessToken, start: start + 100);
      }
    } else {
      setState(() {
        title = "抓取数据失败";
      });
      toast("抓取数据失败，请返回上一页稍后重试");
    }
  }

  _downloadFileToApplicationDir(String accessToken) async {
    Directory directory = await getApplicationDocumentsDirectory();
    int pages = musicList.length % 100 == 0 ? (musicList.length / 100).floor() : ((musicList.length / 100).floor() + 1);
    for (int i = 0; i < pages; i++) {
      var tempMusicList = [];
      if (pages == 1) {
        tempMusicList = musicList;
      } else {
        if (i == pages - 1) {
          tempMusicList = musicList.sublist((i - 1) * 100);
        } else {
          tempMusicList = musicList.sublist((i - 1) * 100, (i + 1) * 100);
        }
      }
      Map<String, dynamic> fsIdCache = {};
      for (var element in tempMusicList) {
        fsIdCache[element.fsId.toString()] = element;
      }
      Map<String, dynamic> fileInfoRes = await BaiduApi.getFileInfo(accessToken, fsIdCache.keys.toList());
      if (fileInfoRes['errno'] != 0) {
        toast("抓取文件信息失败!");
      } else {
        var fileInfoList = fileInfoRes['list'] as List;
        for (var file in fileInfoList) {
          // 写入应用目录
          String savePath = "${directory.path}/mizar_music/${(fsIdCache[file['fs_id'].toString()] as MusicInfoEntity).serverFileName}";
          LoggerHelper.i(savePath);
          await BaiduApi.download("${file['dlink']}&access_token=$accessToken", savePath);
          setState(() {
            downloadCount = downloadCount + 1;
            if (downloadCount == musicList.length) {
              title = "同步完成";
            } else {
              title = "下载中($downloadCount/${musicList.length})";
            }
          });
          // 更新数据库字段
          TableHelper.update('UPDATE "t_music_list" SET "is_sync" = ? WHERE "fs_id" = ?;', [1, file['fs_id']]);
        }
      }
    }
  }

  _fetchBaiduPictureToFill(List<MusicInfoEntity> musicList) async {
    if (musicList.isEmpty) {
      return [];
    }
    for (var element in musicList) {
      element.imageUrl = await BaiduHelper.fetchHoverUrl(element.serverFileName!);
    }
    return musicList;
  }

  Widget _buildMainView() {
    return Scaffold(
      appBar: refAppBar(context: context, title: title),
      body: musicList.isNotEmpty
          ? ListView.custom(
              childrenDelegate: SliverChildBuilderDelegate((context, index) {
                MusicInfoEntity mi = musicList[index];
                return Container(
                  width: double.infinity,
                  height: 54 + (2 * AppSizes.kPaddingSize),
                  padding: const EdgeInsets.all(AppSizes.kPaddingSize),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundColor,
                    border: Border(bottom: BorderSide(width: 5, color: AppColors.middleColor)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 48,
                        width: 48,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(48)),
                        child: Image.network(mi.imageUrl!.isEmpty ? kDefaultUrl : mi.imageUrl!),
                      ),
                      Expanded(
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
                      ),
                    ],
                  ),
                );
              }, childCount: musicList.length),
            )
          : Container(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainView();
  }
}
