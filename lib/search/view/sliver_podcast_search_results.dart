import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '../../app/connectivity_model.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../podcasts/podcast_model.dart';
import '../search_model.dart';
import 'podcast_card.dart';

class SliverPodcastSearchResults extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SliverPodcastSearchResults({
    super.key,
    this.take,
  });

  final int? take;

  @override
  State<SliverPodcastSearchResults> createState() =>
      _SliverPodcastSearchResultsState();
}

class _SliverPodcastSearchResultsState
    extends State<SliverPodcastSearchResults> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    di<PodcastModel>()
        .init(
          updateMessage: context.l10n.newEpisodeAvailable,
        )
        .then((_) => di<SearchModel>().search());
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_SliverPodcastSearchResultsState, build');
    // final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);

    // debugPrint('_SliverPodcastSearchResultsState, build, isOnline: $isOnline');
    // if (!isOnline) {
    //   return const SliverFillRemaining(
    //     hasScrollBody: false,
    //     child: OfflineBody(),
    //   );
    // }

    final loading = watchPropertyValue((SearchModel m) => m.loading);

    final results = watchPropertyValue(
      (SearchModel m) => m.podcastSearchResult,
    );
    final searchResultItems =
        widget.take != null ? results?.take(widget.take!) : results;

    if (searchResultItems == null || searchResultItems.isEmpty) {
      return SliverNoSearchResultPage(
        icon: loading
            ? const SizedBox.shrink()
            : searchResultItems == null
                ? const AnimatedEmoji(AnimatedEmojis.drum)
                : const AnimatedEmoji(AnimatedEmojis.babyChick),
        message: loading
            ? const Progress()
            : Text(
                searchResultItems == null
                    ? context.l10n.search
                    : context.l10n.noPodcastFound,
              ),
      );
    }

    // return SizedBox();

    // return SliverGrid.builder(
    //   itemCount: searchResultItems.length,
    //   gridDelegate: audioCardGridDelegate,
    //   itemBuilder: (context, index) => PodcastCard(
    //     podcastItem: searchResultItems.elementAt(index),
    //   ),
    // );

    return SliverPadding(
      padding: EdgeInsets.zero,
      sliver: DecoratedSliver(
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
        ), // 设置背景色为红色
        sliver: SliverGrid.builder(
          itemCount: searchResultItems.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 210,
            mainAxisExtent: 165,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) => PodcastCard(
            podcastItem: searchResultItems.elementAt(index),
          ),
        ),
      ),
    );
  }
}

class SliverPodcastSearchCountryChartsResults extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const SliverPodcastSearchCountryChartsResults({
    super.key,
    this.take,
    this.expand = true,
  });

  final int? take;
  final bool expand;

  @override
  State<SliverPodcastSearchCountryChartsResults> createState() =>
      _SliverPodcastSearchCountryChartsResultsState();
}

class _SliverPodcastSearchCountryChartsResultsState
    extends State<SliverPodcastSearchCountryChartsResults> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    di<PodcastModel>()
        .init(
          updateMessage: context.l10n.newEpisodeAvailable,
        )
        .then((_) => di<SearchModel>().fetchPodcastChartsPeak());
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);

    final loading = watchPropertyValue((SearchModel m) => m.loading);

    final results = watchPropertyValue(
      (SearchModel m) => m.podcastChartsPeak,
    );
    final searchResultItems =
        widget.take != null ? results?.take(widget.take!) : results;

    if (searchResultItems == null || searchResultItems.isEmpty) {
      return SliverNoSearchResultPage(
        expand: widget.expand,
        icon: loading
            ? const SizedBox.shrink()
            : searchResultItems == null
                ? const AnimatedEmoji(AnimatedEmojis.drum)
                : const AnimatedEmoji(AnimatedEmojis.babyChick),
        message: loading
            ? const Progress()
            : Text(
                searchResultItems == null
                    ? context.l10n.search
                    : context.l10n.noPodcastFound,
              ),
      );
    }

    return SizedBox();
  }
}
