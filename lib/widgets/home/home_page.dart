import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:mizar_music_app/common/index.dart';

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
  }

  @override
  void dispose() {
    searchFocus.dispose();
    controller.dispose();
    super.dispose();
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
          _buildRecommandGroup(groupName: "播放推荐"),
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
        height: 40 + (140.0 + AppSizes.kPaddingSize) * pictures.length * 2 + 10,
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
                return Container(
                  width: 140,
                  height: 140,
                  margin: const EdgeInsets.only(bottom: AppSizes.kPaddingSize),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.kPaddingSize)),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(pictures[index % pictures.length], fit: BoxFit.fill),
                );
              }, childCount: pictures.length * 2),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildRecommandGroup({required String groupName}) {
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
              cacheExtent: 140,
              itemExtent: 140 + AppSizes.kPaddingSize,
              childrenDelegate: SliverChildBuilderDelegate((context, index) {
                return Container(
                  width: 140,
                  height: 140,
                  margin: const EdgeInsets.only(right: AppSizes.kPaddingSize),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSizes.kPaddingSize)),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(pictures[index % pictures.length], fit: BoxFit.fill),
                );
              }, childCount: pictures.length * 2),
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
        child: Swiper(
          itemBuilder: (BuildContext context, int index) {
            return Image.network(pictures[index], fit: BoxFit.fill);
          },
          itemCount: pictures.length,
          pagination: const SwiperPagination(),
          // control: const SwiperControl(),
        ),
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
