import 'package:flutter/material.dart';
import '../theme.dart';

class DoctorNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DoctorNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const items = [
    _NavItem(Icons.dashboard_rounded, "Home"),
    _NavItem(Icons.calendar_today_rounded, "Appointments"),
    _NavItem(Icons.groups_rounded, "Patients"),
    _NavItem(Icons.description_rounded, "Records"),
    _NavItem(Icons.person_rounded, "Profile"),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = currentIndex == i;

              return GestureDetector(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].icon,
                      color: active
                          ? AppColors.darkGreen
                          : AppColors.textMuted,
                    ),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        fontSize: 11,
                        color: active
                            ? AppColors.darkGreen
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem(this.icon, this.label);
}