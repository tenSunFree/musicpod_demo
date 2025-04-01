import 'package:flutter/material.dart';
import 'package:system_theme/system_theme.dart';
import 'mobile_musicpod_app.dart';

class MaterialMusicPodApp extends StatelessWidget {
  const MaterialMusicPodApp({super.key});

  @override
  Widget build(BuildContext context) => SystemThemeBuilder(
        builder: (context, accent) {
          return MobileMusicPodApp(accent: accent.accent);
        },
      );
}
