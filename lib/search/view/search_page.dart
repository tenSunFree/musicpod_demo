import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:watch_it/watch_it.dart';
import '../../common/data/audio_type.dart';
import '../search_model.dart';
import 'sliver_podcast_search_results.dart';

class SearchPage extends StatelessWidget with WatchItMixin {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axisDirection == AxisDirection.down &&
                  notification.direction == ScrollDirection.reverse &&
                  notification.metrics.pixels >=
                      notification.metrics.maxScrollExtent * 0.4 &&
                  audioType != AudioType.local) {
                di<SearchModel>()
                  ..incrementLimit(32)
                  ..search();
              }
              return true;
            },
            child: Container(
              color: Color(0xFFF5F5F5),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: AspectRatio(
                      aspectRatio: 1080 / 357, // 设置宽高比例为308:139
                      child: Image.asset(
                        'assets/images/icon_top_bar.png',
                        fit: BoxFit.contain, // 使图片在维持比例的同时完全显示
                      ),
                    ),
                  ),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.all(10), // 四周填充 16 像素
                          sliver: switch (audioType) {
                            AudioType.radio => SizedBox(),
                            AudioType.podcast =>
                              const SliverPodcastSearchResults(),
                            AudioType.local => SizedBox(),
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: AspectRatio(
                      aspectRatio: 1080 / 124, // 设置宽高比例为308:139
                      child: Image.asset(
                        'assets/images/icon_bottom_bar.png',
                        fit: BoxFit.contain, // 使图片在维持比例的同时完全显示
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
