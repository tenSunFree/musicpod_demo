import '../../common/view/safe_network_image.dart';
import '../../common/view/theme.dart';
import '../../library/library_model.dart';
import '../../podcasts/podcast_model.dart';
import '../../podcasts/podcast_search_state.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class PodcastCard extends StatelessWidget with WatchItMixin {
  const PodcastCard({super.key, required this.podcastItem});

  final PhotoModel podcastItem;

  Color getColorById(int id) {
    const int colorRange = 200; // 設定顏色循環範圍
    int index = id % colorRange;

    // Hue 採用不規則跳躍，確保相似顏色不會連續出現
    List<double> hueSequence = [
      0,
      180,
      60,
      240,
      120,
      300,
      30,
      210,
      90,
      270,
      150,
      330
    ];

    // 讓 ID 對應不同色相
    double hue = hueSequence[index % hueSequence.length];

    // 變化飽和度與亮度，讓相近顏色更加區別
    double saturation = 0.7 + ((index * 17) % 30) / 100; // 0.7 ~ 1.0 變化
    double value = 0.8 + ((index * 23) % 20) / 100; // 0.8 ~ 1.0 變化

    return HSVColor.fromAHSV(
            1.0, hue, saturation.clamp(0.7, 1.0), value.clamp(0.8, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final art = podcastItem.url ?? podcastItem.url;
    debugPrint('PodcastCard, build, art: $art');
    debugPrint('PodcastCard, build, id: ${podcastItem.id}');

    var idColor = getColorById(podcastItem.id);
    debugPrint('PodcastCard, build, idColor: $idColor');
    return Container(
      decoration: BoxDecoration(
        // color: idColor,
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12.0), // 設置圓角
      ),
      alignment: Alignment.center,
      child: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              decoration: BoxDecoration(
                color: idColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              child: Text(
                podcastItem.id.toString(),
                style: const TextStyle(
                  color: Color(0xFF686868),
                  fontWeight: FontWeight.bold, // 粗體
                  fontStyle: FontStyle.italic, // 斜體
                  fontSize: 26.0, // 字體大小
                ),
                maxLines: 2, // 限制最多顯示 2 行
                overflow: TextOverflow.ellipsis, // 超出部分顯示 ...
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              podcastItem.title,
              style: const TextStyle(color: Color(0xFF686868)),
              maxLines: 2, // 限制最多顯示 2 行
              overflow: TextOverflow.ellipsis, // 超出部分顯示 ...
            ),
          ),
        ],
      ),
      // child: AudioCard(
      //   key: ValueKey(feedUrl),
      //   bottom: AudioCardBottom(
      //     text: podcastItem.title ?? podcastItem.title,
      //   ),
      //   image: image,
      //   onPlay: loadingFeed ? null : () => loadPodcast(play: true),
      //   onTap: loadingFeed ? null : () => loadPodcast(play: false),
      // ),
    );
  }
}
