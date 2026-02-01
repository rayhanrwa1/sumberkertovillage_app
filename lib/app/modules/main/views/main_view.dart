import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:sumberkerto_smart_village/app/common/widgets/bottom_navbar.dart';
import 'package:sumberkerto_smart_village/app/modules/home/views/home_view.dart';
import 'package:sumberkerto_smart_village/app/modules/main/controllers/main_controller.dart';
import 'package:sumberkerto_smart_village/app/modules/news/views/news_view.dart';
import 'package:sumberkerto_smart_village/app/modules/profile/views/profile_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.index.value,
          children: const [HomeView(), NewsView(), ProfileView()],
        ),
      ),
      bottomNavigationBar: Obx(
        () => TBottomNavbar(
          currentIndex: controller.index.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}
