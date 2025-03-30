import 'package:flutter/material.dart';

class TopBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String screen;
  const TopBarWidget({super.key, required this.screen});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      title: Text(screen),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
