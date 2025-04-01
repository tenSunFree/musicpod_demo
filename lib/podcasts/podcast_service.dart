import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:podcast_search/podcast_search.dart';
import '../common/data/audio.dart';
import '../library/library_service.dart';
import 'podcast_model.dart';

class PodcastService {
  final LibraryService _libraryService;
  final Dio _dio;
  PodcastService({
    required LibraryService libraryService,
    required Dio dio,
  })  :_libraryService = libraryService,
        _dio = dio;

  SearchResult? _searchResult;
  Search? _search;

  Future<void> init({bool forceInit = false}) async {

  }

  Future<List<PhotoModel>> fetchPhotos() async {
    try {
      final response = await _dio.get('https://jsonplaceholder.typicode.com/photos');
      if (response.statusCode == 200) {
        return (response.data as List).map((json) => PhotoModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load photos');
      }
    } catch (e) {
      throw Exception('Error fetching photos: $e');
    }
  }

  String? _previousQuery;
  Future<List<PhotoModel>?> search({
    String? searchQuery,
    Country? country,
    int limit = 10,
  }) async {
    List<PhotoModel> photoModelList = await fetchPhotos();
    List<PhotoModel> newPhotoModelList = photoModelList.take(limit).toList();
    return newPhotoModelList;
  }

  bool _updateLock = false;

  Future<void> updatePodcasts({
    Map<String, List<Audio>>? oldPodcasts,
    String? updateMessage,
  }) async {
    if (_updateLock) return;
    _updateLock = true;
    for (final old in (oldPodcasts ?? _libraryService.podcasts).entries) {
      if (old.value.isNotEmpty) {
        final list = old.value;
        final firstOld = list.firstOrNull;

        if (firstOld?.website != null) {
          await findEpisodes(
            feedUrl: firstOld!.website!,
          ).then((audios) {
            if (firstOld.year != null &&
                    audios.firstOrNull?.year == firstOld.year ||
                audios.isEmpty) {
              return;
            }

            _libraryService.updatePodcast(old.key, audios);
            if (updateMessage != null) {
              // _notificationsService.notify(
              //   message: '$updateMessage ${firstOld.album ?? old.value}',
              // );
            }
          });
        }
      }
    }
    _updateLock = false;
  }

  Future<List<Audio>> findEpisodes({
    required String feedUrl,
    String? itemImageUrl,
    String? genre,
  }) async {
    final Podcast? podcast = await compute(loadPodcast, feedUrl);
    final episodes = podcast?.episodes
            .where((e) => e.contentUrl != null)
            .map(
              (e) => Audio.fromPodcast(
                episode: e,
                podcast: podcast,
                itemImageUrl: itemImageUrl,
                genre: genre,
              ),
            )
            .toList() ??
        <Audio>[];


    return episodes;
  }
}

Future<Podcast?> loadPodcast(String url) async {
  try {
    return await Podcast.loadFeed(
      url: url,
    );
  } catch (e) {
    return null;
  }
}
