import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:radio_browser_api/radio_browser_api.dart' hide Country;
import 'package:safe_change_notifier/safe_change_notifier.dart';
import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../podcasts/podcast_model.dart';
import '../podcasts/podcast_service.dart';
import 'search_type.dart';

const _initialAudioType = AudioType.podcast;

class SearchModel extends SafeChangeNotifier {
  SearchModel({
    required PodcastService podcastService,
  })  : _podcastService = podcastService;

  final PodcastService _podcastService;

  Set<SearchType> _searchTypes = searchTypesFromAudioType(_initialAudioType);
  Set<SearchType> get searchTypes => _searchTypes;
  AudioType _audioType = _initialAudioType;
  AudioType get audioType => _audioType;
  void setAudioType(AudioType? value) {
    if (value == _audioType || value == null) return;
    _audioType = value;
    _searchTypes = searchTypesFromAudioType(_audioType);
    setSearchType(_searchTypes.first);
  }

  SearchType _searchType = searchTypesFromAudioType(_initialAudioType).first;
  SearchType get searchType => _searchType;
  void setSearchType(SearchType value) {
    _searchType = value;
    notifyListeners();
  }

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    if (value == _searchQuery) return;
    _podcastLimit = podcastDefaultLimit;
    _radioLimit = _radioDefaultLimit;
    _searchQuery = value;
    notifyListeners();
  }

  List<PhotoModel>? _podcastSearchResult;
  List<PhotoModel>? get podcastSearchResult => _podcastSearchResult;
  void setPodcastSearchResult(List<PhotoModel>? value) {
    _podcastSearchResult = value;
    notifyListeners();
  }

  Country? _country;
  Country? get country => _country;
  void setCountry(Country? value) {
    if (value == _country) return;
    _country = value;
    notifyListeners();
  }

  Tag? _tag;
  Tag? get tag => _tag;
  void setTag(Tag? value) {
    if (value == _tag) return;
    _tag = value;
    notifyListeners();
  }

  static const podcastDefaultLimit = 4;
  int _podcastLimit = podcastDefaultLimit;
  void incrementPodcastLimit(int value) => _podcastLimit += value;

  static const _radioDefaultLimit = 64;
  int _radioLimit = _radioDefaultLimit;
  void incrementRadioLimit(int value) => _radioLimit += value;

  void incrementLimit(int value) => _audioType == AudioType.podcast
      ? incrementPodcastLimit(value)
      : incrementRadioLimit(value);

  bool loading = false;
  set _loading(bool value) {
    loading = value;
    notifyListeners();
  }

  Future<void> search({
    bool clear = false,
    bool manualFilter = false,
  }) async {
    _loading = true;
    return await _podcastService
        .search(
      searchQuery: _searchQuery,
      limit: _podcastLimit,
      country: _country,
    )
        .then((v) => setPodcastSearchResult(v))
        .then((_) => _loading = false);
  }

  List<PhotoModel>? _podcastChartsPeak;
  List<PhotoModel>? get podcastChartsPeak => _podcastChartsPeak;
  Future<void> fetchPodcastChartsPeak({int limit = 3}) async {
    _podcastChartsPeak =
        await _podcastService.search(country: _country, limit: limit);
    notifyListeners();
  }
}
