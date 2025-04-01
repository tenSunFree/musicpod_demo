import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import '../common/data/audio.dart';
import 'podcast_search_state.dart';
import 'podcast_service.dart';

class PhotoModel {
  final int albumId;
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  PhotoModel({
    required this.albumId,
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  // 解析 JSON 為 PhotoModel
  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      albumId: json['albumId'],
      id: json['id'],
      title: json['title'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  // 將 PhotoModel 轉回 JSON
  Map<String, dynamic> toJson() {
    return {
      'albumId': albumId,
      'id': id,
      'title': title,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  // 解析 JSON 陣列
  static List<PhotoModel> fromJsonList(String source) {
    final List<dynamic> data = json.decode(source);
    return data.map((json) => PhotoModel.fromJson(json)).toList();
  }
}

class PodcastModel extends SafeChangeNotifier {
  PodcastModel({
    required PodcastService podcastService,
  }) : _podcastService = podcastService;

  final PodcastService _podcastService;

  final _searchStateController =
      StreamController<PodcastSearchState>.broadcast();
  Stream<PodcastSearchState> get stateStream => _searchStateController.stream;
  PodcastSearchState _lastState = PodcastSearchState.done;
  PodcastSearchState get lastState => _lastState;
  void _sendState(PodcastSearchState state) {
    if (state == _lastState) return;
    _lastState = state;
    notifyListeners();
    _searchStateController.add(state);
  }

  var _firstUpdateChecked = false;
  Future<void> init({
    required String updateMessage,
    bool forceInit = false,
    Function({required String message})? notify,
  }) async {
    await _podcastService.init(forceInit: forceInit);

    if (_firstUpdateChecked == false) {
      update(updateMessage: updateMessage);
    }
    _firstUpdateChecked = true;

    notifyListeners();
  }

  void update({
    String? updateMessage,
    // Note: because the podcasts can be modified to include downloads
    // this needs a map and not only the feedurl
    Map<String, List<Audio>>? oldPodcasts,
  }) {
    _setCheckingForUpdates(true);
    _podcastService
        .updatePodcasts(updateMessage: updateMessage, oldPodcasts: oldPodcasts)
        .then((_) => _setCheckingForUpdates(false));
  }

  bool _checkingForUpdates = false;
  bool get checkingForUpdates => _checkingForUpdates;
  void _setCheckingForUpdates(bool value) {
    if (_checkingForUpdates == value) return;
    _checkingForUpdates = value;
    notifyListeners();
  }

  bool _updatesOnly = false;
  bool get updatesOnly => _updatesOnly;
  void setUpdatesOnly(bool value) {
    if (_updatesOnly == value) return;
    _updatesOnly = value;
    notifyListeners();
  }

  bool _downloadsOnly = false;
  bool get downloadsOnly => _downloadsOnly;
  void setDownloadsOnly(bool value) {
    if (_downloadsOnly == value) return;
    _downloadsOnly = value;
    notifyListeners();
  }

  Future<void> loadPodcast({
    required String feedUrl,
    String? itemImageUrl,
    String? genre,
    required Function(List<Audio> podcast) onFind,
  }) async {
    _sendState(PodcastSearchState.loading);

    return _podcastService
        .findEpisodes(
          feedUrl: feedUrl,
          itemImageUrl: itemImageUrl,
          genre: genre,
        )
        .then(
          (podcast) async {
            if (podcast.isEmpty) {
              _sendState(PodcastSearchState.empty);
              return;
            }

            onFind(podcast);
          },
        )
        .whenComplete(
          () => _sendState(PodcastSearchState.done),
        )
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            _sendState(PodcastSearchState.timeout);
          },
        );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _searchStateController.close();
  }
}

void podcastStateStreamHandler(
  BuildContext context,
  AsyncSnapshot<PodcastSearchState?> newValue,
  void Function() cancel,
) {
  if (newValue.hasData) {
    if (newValue.data == PodcastSearchState.done) {
      ScaffoldMessenger.of(context).clearSnackBars();
    } else {

    }
  }
}
