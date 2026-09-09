import 'package:flutter/material.dart';
import 'package:solvoca/ui/lift.dart';
import 'package:solvoca/ui/tokens.dart';

class SolvocaListRow extends StatelessWidget {
  const SolvocaListRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SolvocaLift(
        radius: SolvocaTokens.radiusListRow,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: SolvocaTokens.fontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: SolvocaTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: SolvocaTokens.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: SolvocaTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: SolvocaTokens.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
