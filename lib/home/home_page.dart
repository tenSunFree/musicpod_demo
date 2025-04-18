import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '../common/data/audio_type.dart';
import '../common/page_ids.dart';
import '../common/view/header_bar.dart';
import '../common/view/icons.dart';
import '../common/view/ui_constants.dart';
import '../extensions/country_x.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';
import '../search/search_model.dart';
import '../search/search_type.dart';
import '../search/view/sliver_podcast_search_results.dart';

class HomePage extends StatelessWidget with WatchItMixin {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final playlists = watchPropertyValue(
      (LibraryModel m) => m.playlists.keys.toList(),
    );
    const textPadding = EdgeInsets.only(
      right: kMediumSpace,
      left: kSmallestSpace,
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0), // 設定內邊距
                sliver: SliverToBoxAdapter(
                  child: ListTile(
                    contentPadding: textPadding,
                    title: Text(
                      '${l10n.podcast} ${l10n.charts}',
                      // style: style,
                    ),
                    trailing: Icon(Iconz.goNext),
                    onTap: () {
                      di<LibraryModel>().push(pageId: PageIDs.searchPage);
                      di<SearchModel>()
                        ..setAudioType(AudioType.podcast)
                        ..setSearchType(SearchType.podcastTitle)
                        ..search();
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0), // 設定內邊距
                sliver: const SliverPodcastSearchCountryChartsResults(
                  expand: false,
                  take: 3,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0), // 設定內邊距
                sliver: SliverToBoxAdapter(
                  child: ListTile(
                    contentPadding: textPadding,
                    title: Text(
                      '${l10n.radio} ${l10n.charts}}',
                    ),
                    onTap: () {
                      di<LibraryModel>().push(pageId: PageIDs.searchPage);
                      di<SearchModel>()
                        ..setAudioType(AudioType.radio)
                        ..setSearchType(SearchType.radioCountry)
                        ..search();
                    },
                    trailing: Icon(Iconz.goNext),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0), // 設定內邊距
                sliver: SliverToBoxAdapter(
                  child: ListTile(
                    contentPadding: textPadding,
                    title: Text(l10n.playlists),
                    trailing: Icon(Iconz.goNext),
                    onTap: () {
                      di<LibraryModel>().push(pageId: PageIDs.localAudio);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
