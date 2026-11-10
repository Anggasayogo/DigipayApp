import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class InspectorFab extends StatelessWidget {
  const InspectorFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: 'chucker_fab',
      onPressed: () {
        ChuckerFlutter.showChuckerScreen();
      },
      backgroundColor: AppColors.primaryDark,
      tooltip: 'Open Chucker Inspector',
      child: const Icon(Icons.bug_report_rounded, color: Colors.white, size: 20),
    );
  }
}

class InspectorAppBarAction extends StatelessWidget {
  const InspectorAppBarAction({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Open Chucker Inspector',
      icon: const Icon(Icons.radar_rounded),
      onPressed: () {
        ChuckerFlutter.showChuckerScreen();
      },
    );
  }
}
