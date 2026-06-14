import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../routes/my_app_router_const.dart';
import 'drawer_header.dart';
import 'drawer_item.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(height: 50),
          const DrawerHeaderSection(),
          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                DrawerItem(
                  icon: HugeIcons.strokeRoundedDashboardSquare01,
                  title: 'Home',
                  onTap: () {
                    context.pop();
                    context.go(MyAppRouteConst.home);
                  },
                ),
                DrawerItem(
                  icon: HugeIcons.strokeRoundedUser,
                  title: 'Profile',
                  onTap: () {
                    context.push(MyAppRouteConst.profile);
                    context.pop();
                  },
                ),
                DrawerItem(
                  icon: HugeIcons.strokeRoundedRadar01,
                  title: 'Transactions',
                  onTap: () {
                    context.push(MyAppRouteConst.transactions);
                    context.pop();
                  },
                ),
              ],
            ),
          ),

          const Padding(padding: EdgeInsets.all(8.0), child: Text("v1.0.0")),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
