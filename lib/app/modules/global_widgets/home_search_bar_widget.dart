import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../search/controllers/search_controller.dart' as searchController;

class HomeSearchBarWidget extends StatelessWidget implements PreferredSize {
  final controller = Get.find<searchController.SearchController>();

  @override
  Widget build(BuildContext context) {
    return Container(); // or any other placeholder widget
  }

  @override
  Widget get child => Container(); // or any other placeholder widget

  @override
  Size get preferredSize => new Size(0, 0); // Return a zero-sized widget
}
