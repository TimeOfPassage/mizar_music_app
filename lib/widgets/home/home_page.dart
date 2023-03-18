import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:mizar_music_app/common/index.dart';
import 'package:mizar_music_app/entity/music_info.dart';

import '../../utils/index.dart';
import 'music_play_page.dart';

/// home page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController controller;
  late FocusNode searchFocus;
  String? searchText;

  ///
  List<MusicInfoEntity>? musicList;
  List<MusicInfoEntity>? top10MusicList;

  List<String> pictures = [
    "https://scpic.chinaz.net/files/default/imgs/2022-12-08/060ef5cce6f18457.jpg",
    "https://scpic.chinaz.net/files/default/imgs/2023-02-03/adc77c8e5c94d758.jpg",
    "https://scpic.chinaz.net/files/default/imgs/2023-02-21/f16006bc317bae03.jpg",
    "https://scpic.chinaz.net/files/default/imgs/2023-01-07/6231247f737c8ef0.jpg",
    "https://scpic.chinaz.net/files/default/imgs/2023-01-10/cd370beec9416f2c.jpg"
  ];

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    searchFocus = FocusNode();
    // 随机获取三首音乐
    _randomFetchThreeMusic();
  }

  @override
  void dispose() {
    searchFocus.dispose();
    controller.dispose();
    super.dispose();
  }

  _randomFetchThreeMusic() async {
    List<MusicInfoEntity> mList = await MusicHelper.randomFetchThreeMusicList();
    if (mList.isEmpty) {
      return;
    }
    top10MusicList = mList;
    mList.shuffle(Random());
    if (mList.length > 3) {
      mList = mList.sublist(0, 3);
    }
    setState(() {
      musicList = mList;
    });
  }

  Widget _buildMainView() {
    return GestureDetector(
      onTap: () => searchFocus.unfocus(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.kPaddingSize),
        child: CustomScrollView(slivers: [
          // build appbar
          _buildSliveAppBar(),
          // build swiper
          _buildSwiper(),
          // build recommand music group
          _buildRecommandGroup(groupName: "常用分组", childTexts: ["全部音乐", "常用播放"]),
          // build top 10 play
          _buildTop10Group(groupName: "Top10播放"),
        ]),
      ),
    );
  }

  Widget _buildTop10Group({required String groupName}) {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        height: 40 + (140.0 + AppSizes.kPaddingSize) * ((top10MusicList ?? []).length) + 10,
        margin: const EdgeInsets.only(top: AppSizes.kPaddingSize),
        child: Column(children: [
          // group title
          SizedBox(
            width: double.infinity,
            height: 40,
            child: Text(groupName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          // group music list
          Expanded(
            child: ListView.custom(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              childrenDelegate: SliverChildBuilderDelegate((context, index) {
                MusicInfoEntity mi = top10MusicList![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MusicPlayPage(musicList: top10MusicList!, currentIdx: index)));
                  },
                  child: Container(
                    width: 140,
                    height: 140,
                    margin: const EdgeInsets.only(bottom: AppSizes.kPaddingSize),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.kPaddingSize)),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(mi.imageUrl ?? kDefaultUrl, fit: BoxFit.fill),
                  ),
                );
              }, childCount: (top10MusicList ?? []).length),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildRecommandGroup({required String groupName, required List<String> childTexts}) {
    double w = (MediaQuery.of(context).size.width - 4 * AppSizes.kGapSize) / 2;
    return SliverToBoxAdapter(
      child: Card(
        color: AppColors.backgroundColor,
        margin: const EdgeInsets.symmetric(vertical: AppSizes.kGapSize),
        elevation: 0,
        child: Column(children: [
          // group title
          SizedBox(
            width: double.infinity,
            height: 40,
            child: Text(groupName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          // group music list
          SizedBox(
            height: 120,
            width: double.infinity,
            child: ListView.custom(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              childrenDelegate: SliverChildBuilderDelegate((context, index) {
                return Stack(children: [
                  Container(
                    width: w,
                    height: 140,
                    margin: const EdgeInsets.only(right: AppSizes.kPaddingSize),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.kPaddingSize)),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(pictures[index], fit: BoxFit.fill),
                  ),
                  Container(
                    width: w,
                    height: 140,
                    margin: const EdgeInsets.only(right: AppSizes.kPaddingSize),
                    decoration: BoxDecoration(color: Colors.black.withAlpha(100), borderRadius: BorderRadius.circular(AppSizes.kPaddingSize)),
                  ),
                  Container(
                    width: w,
                    height: 140,
                    margin: const EdgeInsets.only(right: AppSizes.kPaddingSize),
                    child: Center(
                      child: Text(
                        childTexts[index],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppColors.middleColor),
                      ),
                    ),
                  ),
                ]);
              }, childCount: 2),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSwiper() {
    return SliverToBoxAdapter(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 220,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(vertical: AppSizes.kGapSize),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.kPaddingSize)),
        child: musicList != null
            ? Swiper(
                itemBuilder: (BuildContext context, int index) {
                  // MusicInfoEntity mi = musicList![index];
                  // return Image.network(mi.imageUrl!, fit: BoxFit.fill);
                  MusicInfoEntity mi = musicList![index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MusicPlayPage(musicList: musicList!, currentIdx: index)));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(image: NetworkImage(mi.imageUrl!), fit: BoxFit.fill),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Text(mi.musicName ?? "Unknown", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                        AppSizes.boxH10,
                        Text(mi.author ?? "Unknown Author", style: const TextStyle(fontSize: 15, color: Colors.white)),
                      ]),
                    ),
                  );
                },
                itemCount: musicList!.length,
                pagination: const SwiperPagination(),
                // control: const SwiperControl(),
              )
            : const Text("请先同步音乐信息\n 设置->存储设置->百度云设置"),
      ),
    );
  }

  Widget _buildSliveAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundColor,
      elevation: 0,
      pinned: true,
      titleSpacing: 0,
      actions: const [Icon(Icons.file_upload_outlined, color: Colors.black54, size: 30)],
      title: Container(
        width: MediaQuery.of(context).size.width,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.kPaddingSize / 2),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textColor),
          borderRadius: BorderRadius.circular(AppSizes.kGapSize),
        ),
        child: TextField(
          controller: controller,
          focusNode: searchFocus,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            prefixIconConstraints: BoxConstraints.tight(const Size.fromWidth(24)),
            hintText: "音乐搜索",
            suffixIcon: searchText != null
                ? IconButton(
                    onPressed: () {
                      controller.clear();
                      setState(() {
                        searchText = null;
                      });
                    },
                    icon: const Icon(Icons.clear))
                : const SizedBox.shrink(),
          ),
          maxLines: 1,
          autocorrect: false,
          contextMenuBuilder: null,
          textInputAction: TextInputAction.search,
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          onSubmitted: (value) {
            searchFocus.unfocus();
            if (value.isEmpty) {
              return;
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainView();
  }
}
