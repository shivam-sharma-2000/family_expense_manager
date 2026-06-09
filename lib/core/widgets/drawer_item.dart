import 'package:flutter/material.dart';

import '../extensions/theme_extension.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final int? badgeCount;
  final Color? color;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.badgeCount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? context.theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsetsGeometry.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: itemColor),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: itemColor,
                  ),
                ),
              ),
              if (badgeCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
