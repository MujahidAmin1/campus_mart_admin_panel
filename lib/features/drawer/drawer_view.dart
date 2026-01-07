import 'package:campus_mart_admin/core/utils/my_colors.dart';
import 'package:campus_mart_admin/features/auth/controller/auth_controller.dart';
import 'package:campus_mart_admin/features/drawer/allproducts/allproducts.dart';
import 'package:campus_mart_admin/features/drawer/drawerCont.dart';
import 'package:campus_mart_admin/features/drawer/history/history_screen.dart';
import 'package:campus_mart_admin/features/drawer/pending%20delivery/view/pend_deliv_view.dart';
import 'package:campus_mart_admin/features/drawer/statistics/stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawerView extends ConsumerWidget {
  const DrawerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentScreen = ref.watch(currentScreenProvider) ?? 0;
    List<Widget> screens = [
      AllProductsScreen(),
      PendingDeliveryView(),
      StatsScreen(),
      HistoryScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Permanent side navigation
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: MyColors.purpleShade,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MyColors.purpleShade,
                    border: Border(
                      bottom: BorderSide(
                        color: MyColors.warmGold.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Campus Mart\nAdmin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                // Navigation items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildNavItem(
                        context: context,
                        ref: ref,
                        icon: Icons.inventory,
                        title: "All Products",
                        index: 0,
                        currentScreen: currentScreen,
                      ),
                      _buildNavItem(
                        context: context,
                        ref: ref,
                        icon: Icons.local_shipping_outlined,
                        title: 'Pending Delivery',
                        index: 1,
                        currentScreen: currentScreen,
                      ),
                      _buildNavItem(
                        context: context,
                        ref: ref,
                        icon: Icons.analytics_outlined,
                        title: 'Statistics',
                        index: 2,
                        currentScreen: currentScreen,
                      ),
                      _buildNavItem(
                        context: context,
                        ref: ref,
                        icon: Icons.history,
                        title: 'History',
                        index: 3,
                        currentScreen: currentScreen,
                      ),
                      SizedBox(height: 50),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          minimumSize: Size(400, 30),
                          backgroundColor: MyColors.purpleShade,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Logout'),
                              content: Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .signout();
                                    Navigator.pop(context);
                                  },

                                  child: Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text('Log out'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Top app bar for main content
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        _getScreenTitle(currentScreen),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: MyColors.darkBase,
                        ),
                      ),
                    ],
                  ),
                ),
                // Screen content
                Expanded(
                  child: IndexedStack(index: currentScreen, children: screens),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required int index,
    required int currentScreen,
  }) {
    final isSelected = currentScreen == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? MyColors.warmGold.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? MyColors.warmGold : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? MyColors.warmGold : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          navigateTo(ref, index);
        },
      ),
    );
  }

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return 'All Products';
      case 1:
        return 'Pending Delivery';
      case 2:
        return 'Statistics';
      case 3:
        return 'History';
      default:
        return 'Campus Mart Admin';
    }
  }
}
