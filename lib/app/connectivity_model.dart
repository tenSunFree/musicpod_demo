import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import '../extensions/connectivity_x.dart';
import '../l10n/l10n.dart';

class ConnectivityModel extends SafeChangeNotifier {
  ConnectivityModel({
    required Connectivity connectivity,
  })  : _connectivity = connectivity;

  final Connectivity _connectivity;
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  Future<void> init() async {
    // TODO: fix https://github.com/fluttercommunity/plus_plugins/issues/1451
    final fallback = [ConnectivityResult.wifi];

    _connectivitySubscription ??= _connectivity.onConnectivityChanged.listen(
      _updateConnectivity,
      onError: (e) => _result = fallback,
    );

    return _connectivity
        .checkConnectivity()
        .then(_updateConnectivity)
        .catchError((_) => _updateConnectivity(fallback));
  }

  bool get isOnline => _connectivity.isOnline(_result);

  bool get isMaybeLowBandWidth => _connectivity.isNotWifiNorEthernet(_result);

  List<ConnectivityResult>? get result => _result;
  List<ConnectivityResult>? _result;
  void _updateConnectivity(List<ConnectivityResult> newResult) {

    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    super.dispose();
  }
}

void onConnectivityChangedHandler(
  BuildContext context,
  AsyncSnapshot<List<ConnectivityResult>?> res,
  void Function() cancel,
) {
  final l10n = context.l10n;



}
