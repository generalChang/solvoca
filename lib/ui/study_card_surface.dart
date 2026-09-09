import 'package:flutter/material.dart';
import 'package:solvoca/ui/lift.dart';
import 'package:solvoca/ui/tokens.dart';

class StudyCardSurface extends StatelessWidget {
  const StudyCardSurface({
    super.key,
    required this.front,
    required this.back,
    required this.revealed,
  });

  final String front;
  final String back;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    return SolvocaLift(
      radius: SolvocaTokens.radiusStudyCard,
      child: SizedBox(
        height: SolvocaTokens.studyCardHeight,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                front,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: SolvocaTokens.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: SolvocaTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: revealed ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: Text(
                  back,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: SolvocaTokens.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                    color: SolvocaTokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
