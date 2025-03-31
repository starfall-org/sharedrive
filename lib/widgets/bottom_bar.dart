import 'package:flutter/material.dart';

class BottomBarWidget extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  const BottomBarWidget({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomBarWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
      currentIndex: widget.selectedIndex,
      onTap: widget.onItemTapped,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.book), label: "Drive"),
        BottomNavigationBarItem(icon: Icon(Icons.collections), label: "Photos"),
      ],
    );
  }
}
