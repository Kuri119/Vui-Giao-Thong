import 'package:flutter/material.dart';
import 'package:testing/data/notifiers.dart';

class NavbarWidget extends StatelessWidget {
	const NavbarWidget ({super.key});

	@override
	Widget build(BuildContext context) {
		return ValueListenableBuilder(
      valueListenable: selectedPageNotifier, 
      builder: (context, selectedPage, child) {
        return NavigationBar(
          backgroundColor: Color(0xFF00D6FF),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.video_library),
              label: 'Danh sách Video',
            ),
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Màn hình chính',
            ),
            NavigationDestination(
              icon: Icon(Icons.signpost),
              label: 'Danh sách biển báo',
            ),
          ],
          onDestinationSelected: (int value) {
            selectedPageNotifier.value = value;
          },
          selectedIndex: selectedPage,
        );
      },
    );
	} 
}