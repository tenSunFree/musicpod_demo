import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:watch_it/watch_it.dart';
import '../../app_config.dart';
import '../../common/page_ids.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../connectivity_model.dart';
import 'master_items.dart';
import 'mobile_page.dart';

class MobileMusicPodApp extends StatefulWidget with WatchItStatefulWidgetMixin {
  const MobileMusicPodApp({super.key, this.accent});

  final Color? accent;

  @override
  State<MobileMusicPodApp> createState() => _MobileMusicPodAppState();
}

class _MobileMusicPodAppState extends State<MobileMusicPodApp> {
  late Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<bool> _init() async {
    await di<ConnectivityModel>().init();
    await di<LibraryModel>().init();
    if (!mounted) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('_MobileMusicPodAppState, build');
    final themeIndex = 1;
    final phoenix = phoenixTheme(color: widget.accent ?? Colors.greenAccent);

    final libraryModel = watchIt<LibraryModel>();
    final masterItems = createMasterItems(libraryModel: libraryModel);

    return MaterialApp(
      navigatorKey: libraryModel.masterNavigatorKey,
      navigatorObservers: [libraryModel],
      initialRoute: isMobilePlatform
          ? (PageIDs.searchPage)
          : null,
      onGenerateRoute: (settings) {
        debugPrint('_MobileMusicPodAppState, build, settings.name: ${settings.name}');
        final page = (masterItems.firstWhereOrNull(
                  (e) => e.pageId == settings.name,
                ) ??
                masterItems.elementAt(0))
            .pageBuilder(context);

        debugPrint('_MobileMusicPodAppState, build, page: ${page}');
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => FutureBuilder(
            future: _initFuture,
            builder: (context, snapshot) => MobilePage(page: page),
          ),
        );
      },
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.values[themeIndex],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: supportedLocales,
      onGenerateTitle: (context) => kAppTitle,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
          PointerDeviceKind.trackpad,
        },
      ),
    );
  }
}
