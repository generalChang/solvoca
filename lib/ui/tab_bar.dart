import 'package:flutter/material.dart';
import 'package:solvoca/ui/lift.dart';
import 'package:solvoca/ui/tokens.dart';

class SolvocaTabBar extends StatelessWidget {
  const SolvocaTabBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SolvocaLift(
      radius: SolvocaTokens.radiusTabPill,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _Segment(
            icon: Icons.today_outlined,
            label: '오늘',
            selected: selectedIndex == 0,
            onTap: () => onSelect(0),
          ),
          _Segment(
            icon: Icons.style_outlined,
            label: '카드',
            selected: selectedIndex == 1,
            onTap: () => onSelect(1),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? SolvocaTokens.accent : SolvocaTokens.textSecondary;

    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SolvocaTokens.radiusTabSegment),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? SolvocaTokens.accentSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(
                SolvocaTokens.radiusTabSegment,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: SolvocaTokens.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
