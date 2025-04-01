import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import '../../extensions/build_context_x.dart';
import '../../podcasts/podcast_model.dart';
import '../app_model.dart';

class MobilePage extends StatelessWidget with WatchItMixin {
  const MobilePage({
    super.key,
    required this.page,
  });

  final Widget page;

  @override
  Widget build(BuildContext context) {
    final fullWindowMode =
        watchPropertyValue((AppModel m) => m.fullWindowMode) ?? false;

    return PopScope(
      canPop: !fullWindowMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (fullWindowMode) {
          di<AppModel>().setFullWindowMode(false);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        extendBodyBehindAppBar: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            page,
          ],
        ),
      ),
    );
  }
}
