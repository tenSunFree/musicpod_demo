import 'package:package_info_plus/package_info_plus.dart';
import 'app/app_model.dart';
import 'app_config.dart';
import 'constants.dart';
import 'dart:io';
import 'library/library_model.dart';
import 'library/library_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_discord_rpc/flutter_discord_rpc.dart';
import 'package:github/github.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/watch_it.dart';
import 'persistence_utils.dart';
import 'podcasts/podcast_model.dart';
import 'podcasts/podcast_service.dart';
import 'search/search_model.dart';

/// Registers all Services, ViewModels and external dependencies
/// Note: we want lazy registration whenever possible, preferable without any async calls above.
/// Sometimes this is not possible and we need to await a Future before we can register.
Future<void> registerDependencies({required List<String> args}) async {
  if (allowDiscordRPC) {
    await FlutterDiscordRPC.initialize(kDiscordApplicationId);
    di.registerSingleton<FlutterDiscordRPC>(
      FlutterDiscordRPC.instance,
      dispose: (s) {
        s.disconnect();
        s.dispose();
      },
    );
  }

  final String? downloadsDefaultDir = await getDownloadsDefaultDir();
  final sharedPreferences = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();

  di
    ..registerSingleton<SharedPreferences>(sharedPreferences)
    ..registerSingleton<PackageInfo>(packageInfo)
    ..registerLazySingleton<Dio>(
      () => Dio(),
      dispose: (s) => s.close(),
    )
    ..registerLazySingleton<LibraryService>(
      () => LibraryService(sharedPreferences: di<SharedPreferences>()),
      dispose: (s) async => s.dispose(),
    )
    ..registerLazySingleton<PodcastService>(
      () => PodcastService(
        libraryService: di<LibraryService>(),
        dio: di<Dio>(),
      ),
    )
    ..registerLazySingleton<Connectivity>(() => Connectivity())
    ..registerLazySingleton<GitHub>(() => GitHub())
    ..registerLazySingleton<AppModel>(
      () => AppModel(
        packageInfo: di<PackageInfo>(),
        gitHub: di<GitHub>(),
        allowManualUpdates: Platform.isLinux ? false : true,
      ),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<LibraryModel>(
      () => LibraryModel(di<LibraryService>()),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<PodcastModel>(
      () => PodcastModel(podcastService: di.get<PodcastService>()),
      dispose: (s) => s.dispose(),
    )
    ..registerLazySingleton<SearchModel>(
      () => SearchModel(
        podcastService: di<PodcastService>(),
      ),
    );
}
