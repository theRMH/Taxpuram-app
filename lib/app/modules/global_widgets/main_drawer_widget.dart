/*
 * Copyright (c) 2020 .
 */

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shop/routes/routes.dart' as shopRoutes;
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/settings_service.dart';
import '../custom_pages/views/custom_page_drawer_link_widget.dart';
import '../root/controllers/root_controller.dart' show RootController;
import 'drawer_link_widget.dart';

class MainDrawerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Obx(() {
            if (!Get.find<AuthService>().isAuth) {
              return GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.LOGIN);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(0.1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome".tr, style: Get.textTheme.headlineSmall!.merge(TextStyle(color: Get.theme.colorScheme.secondary))),
                      SizedBox(height: 5),
                      Text("Login account or create new one for free".tr, style: Get.textTheme.bodyLarge),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        children: <Widget>[
                          MaterialButton(
                            onPressed: () {
                              Get.toNamed(Routes.LOGIN);
                            },
                            color: Get.theme.colorScheme.secondary,
                            height: 40,
                            elevation: 0,
                            child: Wrap(
                              runAlignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 9,
                              children: [
                                Icon(Icons.exit_to_app_outlined, color: Get.theme.primaryColor, size: 24),
                                Text(
                                  "Login".tr,
                                  style: Get.textTheme.titleMedium!.merge(TextStyle(color: Get.theme.primaryColor)),
                                ),
                              ],
                            ),
                            shape: StadiumBorder(),
                          ),
                          MaterialButton(
                            color: Get.theme.focusColor.withOpacity(0.2),
                            height: 40,
                            elevation: 0,
                            onPressed: () {
                              Get.toNamed(Routes.REGISTER);
                            },
                            child: Wrap(
                              runAlignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 9,
                              children: [
                                Icon(Icons.person_add_outlined, color: Get.theme.hintColor, size: 24),
                                Text(
                                  "Register".tr,
                                  style: Get.textTheme.titleMedium!.merge(TextStyle(color: Get.theme.hintColor)),
                                ),
                              ],
                            ),
                            shape: StadiumBorder(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return GestureDetector(
                onTap: () async {
                  await Get.find<RootController>().changePage(3);
                },
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(0.1),
                  ),
                  accountName: Text(
                    Get.find<AuthService>().user.value.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  accountEmail: Text(
                    Get.find<AuthService>().user.value.email,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  currentAccountPicture: Stack(
  children: [
    SizedBox(
      width: 80,
      height: 80,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(80)),
        child: Image.asset(
          'assets/img/avatar_default.png', // Replace with the actual path to your local asset image
          fit: BoxFit.cover,
          width: double.infinity,
          height: 80,
        ),
      ),
    ),
    Positioned(
      top: 0,
      right: 0,
      child: Get.find<AuthService>().user.value.verifiedPhone ? Icon(Icons.check_circle, color: Get.theme.colorScheme.secondary, size: 24) : SizedBox(),
    )
  ],
),

                ),
              );
            }
          }),
          SizedBox(height: 20),
          DrawerLinkWidget(
            icon: Icons.home_outlined,
            text: "Home",
            onTap: (e) async {
              Get.back();
              await Get.find<RootController>().changePage(0);
            },
          ),
          DrawerLinkWidget(
            icon: Icons.folder_special_outlined,
            text: "Categories",
            onTap: (e) {
              Get.offAndToNamed(Routes.CATEGORIES);
            },
          ),
          DrawerLinkWidget(
            icon: Icons.assignment_outlined,
            text: "Bookings",
            onTap: (e) async {
              Get.back();
              await Get.find<RootController>().changePage(1);
            },
          ),
          DrawerLinkWidget(
            icon: Icons.notifications_none_outlined,
            text: "Notifications",
            onTap: (e) {
              Get.offAndToNamed(Routes.NOTIFICATIONS);
            },
          ),
          
          
          if (Get.find<SettingsService>().isModuleActivated("Shop"))
            ListTile(
              dense: true,
              title: Text(
                "Shop".tr,
                style: Get.textTheme.bodySmall,
              ),
              trailing: Icon(
                Icons.remove,
                color: Get.theme.focusColor.withOpacity(0.3),
              ),
            ),
          if (Get.find<SettingsService>().isModuleActivated("Shop"))
            DrawerLinkWidget(
              icon: Icons.category_outlined,
              text: "Product Categories",
              onTap: (e) async {
                await Get.offAndToNamed(shopRoutes.Routes.CATEGORIES);
              },
            ),
          if (Get.find<SettingsService>().isModuleActivated("Shop"))
            DrawerLinkWidget(
              icon: Icons.assignment_outlined,
              text: "Orders",
              onTap: (e) async {
                await Get.offAndToNamed(shopRoutes.Routes.ORDERS);
              },
            ),
          ListTile(
            dense: true,
            title: Text(
              "Application preferences".tr,
              style: Get.textTheme.bodySmall,
            ),
            trailing: Icon(
              Icons.remove,
              color: Get.theme.focusColor.withOpacity(0.3),
            ),
          ),
          
          DrawerLinkWidget(
            icon: Icons.person_outline,
            text: "Account",
            onTap: (e) async {
              Get.back();
              await Get.find<RootController>().changePage(3);
            },
          ),
          DrawerLinkWidget(
            icon: Icons.settings_outlined,
            text: "Settings",
            onTap: (e) async {
              await Get.offAndToNamed(Routes.SETTINGS);
            },
          ),
          
          ListTile(
            dense: true,
            title: Text(
              "Help & Privacy",
              style: Get.textTheme.bodySmall,
            ),
            trailing: Icon(
              Icons.remove,
              color: Get.theme.focusColor.withOpacity(0.3),
            ),
          ),
          DrawerLinkWidget(
            icon: Icons.help_outline,
            text: "Help & FAQ",
            onTap: (e) async {
              await Get.offAndToNamed(Routes.HELP);
            },
          ),
          CustomPageDrawerLinkWidget(),
          Obx(() {
            if (Get.find<AuthService>().isAuth) {
              return DrawerLinkWidget(
                icon: Icons.logout,
                text: "Logout",
                onTap: (e) async {
                  await Get.find<AuthService>().removeCurrentUser();
                  Get.back();
                  await Get.find<RootController>().changePage(0);
                },
              );
            } else {
              return SizedBox(height: 0);
            }
          }),
          if (Get.find<SettingsService>().setting.value.enableVersion ?? false)
            ListTile(
              dense: true,
              title: Text(
                "Version".tr + " " + (Get.find<SettingsService>().setting.value.appVersion ?? '1.0.0'),
                style: Get.textTheme.bodySmall,
              ),
              trailing: Icon(
                Icons.remove,
                color: Get.theme.focusColor.withOpacity(0.3),
              ),
            )
        ],
      ),
    );
  }
}
