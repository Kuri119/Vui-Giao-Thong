import 'package:flutter/material.dart';
import 'package:testing/data/notifiers.dart';
import 'package:testing/views/pages/home_page.dart';
import 'package:testing/views/pages/signpost_page.dart';
import 'package:testing/views/pages/video_page.dart';
import 'widgets/navbar_widget.dart';

List<Widget> pages = [
  VideoPage(),
  HomePage(),
  SignpostPage(),
];

class WidgetTree extends StatelessWidget{
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: selectedPageNotifier,
        builder: (BuildContext context, dynamic selectedPage, Widget? child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}