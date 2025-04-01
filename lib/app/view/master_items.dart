import 'package:flutter/material.dart';
import '../../app_config.dart';
import '../../common/page_ids.dart';
import '../../common/view/icons.dart';
import '../../home/home_page.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/view/search_page.dart';

class MasterItem {
  MasterItem({
    required this.titleBuilder,
    this.subtitleBuilder,
    required this.pageBuilder,
    this.iconBuilder,
    required this.pageId,
  });

  final WidgetBuilder titleBuilder;
  final WidgetBuilder? subtitleBuilder;
  final WidgetBuilder pageBuilder;
  final Widget Function(bool selected)? iconBuilder;
  final String pageId;
}

List<MasterItem> createMasterItems({required LibraryModel libraryModel}) {
  return [
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.search),
      pageBuilder: (_) => const SearchPage(),
      iconBuilder: (_) => Icon(Iconz.search),
      pageId: PageIDs.searchPage,
    ),
    if (isMobilePlatform)
      MasterItem(
        titleBuilder: (context) => Text(context.l10n.home),
        iconBuilder: (selected) =>
            Icon(selected ? Iconz.homeFilled : Iconz.home),
        pageBuilder: (context) => const HomePage(),
        pageId: PageIDs.homePage,
      ),
    MasterItem(
      iconBuilder: (selected) => Icon(Iconz.plus),
      titleBuilder: (context) => Text(context.l10n.add),
      pageBuilder: (_) => const SizedBox.shrink(),
      pageId: PageIDs.newPlaylist,
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.likedSongs),
      pageId: PageIDs.likedAudios,
      pageBuilder: (_) => const SizedBox(),
      subtitleBuilder: (context) => Text(context.l10n.playlist),
      iconBuilder: (selected) => SizedBox(),
    ),
  ];
}
