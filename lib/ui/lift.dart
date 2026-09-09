import 'package:flutter/material.dart';
import 'package:solvoca/ui/tokens.dart';

/// One decorated container for radius + shadow. Ink/Material shadows stay off
/// this primitive so elevation follows the rounded shape.
class SolvocaLift extends StatelessWidget {
  const SolvocaLift({
    super.key,
    required this.child,
    this.radius = SolvocaTokens.radiusListRow,
    this.color = SolvocaTokens.surface,
    this.border,
    this.padding,
    this.shadow = true,
  });

  final Widget child;
  final double radius;
  final Color color;
  final BoxBorder? border;
  final EdgeInsetsGeometry? padding;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: shadow ? SolvocaTokens.liftShadow : null,
      ),
      child: child,
    );
  }
}
