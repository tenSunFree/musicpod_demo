import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';

class MainPageIcon extends StatelessWidget with WatchItMixin {
  const MainPageIcon({
    super.key,
    required this.selected,
    required this.audioType,
  });

  final bool selected;
  final AudioType audioType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        selected
            ? audioType.selectedIconDataMainPage
            : audioType.iconDataMainPage,
      ),
    );
  }
}
