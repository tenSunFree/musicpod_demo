import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:github/github.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import '../app_config.dart';
import '../constants.dart';

class AppModel extends SafeChangeNotifier {
  AppModel({
    required PackageInfo packageInfo,
    required GitHub gitHub,
    required bool allowManualUpdates,
  })  : _countryCode = WidgetsBinding
            .instance.platformDispatcher.locale.countryCode
            ?.toLowerCase(),
        _gitHub = gitHub,
        _allowManualUpdates = allowManualUpdates,
        _packageInfo = packageInfo;

  final GitHub _gitHub;
  final bool _allowManualUpdates;
  bool get allowManualUpdate => _allowManualUpdates;

  final String? _countryCode;
  String? get countryCode => _countryCode;

  bool _showWindowControls = true;
  bool get showWindowControls => _showWindowControls;
  void setShowWindowControls(bool value) {
    _showWindowControls = value;
    notifyListeners();
  }

  bool _showQueueOverlay = false;
  bool get showQueueOverlay => _showQueueOverlay;
  void setOrToggleQueueOverlay({bool? value}) {
    _showQueueOverlay = value ?? !_showQueueOverlay;
    notifyListeners();
  }

  bool? _fullWindowMode;
  bool? get fullWindowMode => _fullWindowMode;
  Future<void> setFullWindowMode(bool? value) async {
    if (value == null || value == _fullWindowMode) return;
    _fullWindowMode = value;

    if (isMobilePlatform) {
      if (_fullWindowMode == true) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
        await SystemChrome.setPreferredOrientations(
          [],
        );
      }
    }

    notifyListeners();
  }

  final PackageInfo _packageInfo;
  String get version => _packageInfo.version;

  bool? _updateAvailable;
  bool? get updateAvailable => _updateAvailable;
  String? _onlineVersion;
  String? get onlineVersion => _onlineVersion;
  Future<void> checkForUpdate({
    required bool isOnline,
    Function(String error)? onError,
  }) async {
    _updateAvailable == null;
    notifyListeners();

    if (!_allowManualUpdates || !isOnline) {
      _updateAvailable = false;
      notifyListeners();
      return Future.value();
    }
    _onlineVersion = await getOnlineVersion().onError(
      (error, stackTrace) {
        onError?.call(error.toString());
        return null;
      },
    );
    final onlineVersion = getExtendedVersionNumber(_onlineVersion) ?? 0;
    final currentVersion = getExtendedVersionNumber(version) ?? 0;
    if (onlineVersion > currentVersion) {
      _updateAvailable = true;
    } else {
      _updateAvailable = false;
    }
    notifyListeners();
  }

  int? getExtendedVersionNumber(String? version) {
    if (version == null) return null;
    version = version.replaceAll('v', '');
    List versionCells = version.split('.');
    versionCells = versionCells.map((i) => int.parse(i)).toList();
    return versionCells[0] * 100000 + versionCells[1] * 1000 + versionCells[2];
  }

  Future<String?> getOnlineVersion() async {
    final release = await _gitHub.repositories
        .listReleases(RepositorySlug.full(kGitHubShortLink))
        .toList();
    return release.firstOrNull?.tagName;
  }

  Future<List<Contributor>> getContributors() async {
    final list = await _gitHub.repositories
        .listContributors(
          RepositorySlug.full(kGitHubShortLink),
        )
        .where((c) => c.type == 'User')
        .toList();
    return [
      ...list,
      Contributor(
        login: 'ubuntujaggers',
        htmlUrl: 'https://github.com/ubuntujaggers',
        avatarUrl: 'https://avatars.githubusercontent.com/u/38893390?v=4',
      ),
    ];
  }
}

void discordConnectedHandler(context, snapshot, cancel) {
  // if (snapshot.data == true) {
  //   showSnackBar(
  //     context: context,
  //     duration: const Duration(seconds: 3),
  //     content: DiscordConnectContent(connected: snapshot.data == true),
  //   );
  // }
}
