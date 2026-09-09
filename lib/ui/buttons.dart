import 'package:flutter/material.dart';
import 'package:solvoca/ui/tokens.dart';

class SolvocaPrimaryButton extends StatelessWidget {
  const SolvocaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: compact ? 44 : SolvocaTokens.buttonHeight,
      child: Material(
        color: SolvocaTokens.accent,
        borderRadius: BorderRadius.circular(SolvocaTokens.radiusButton),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(SolvocaTokens.radiusButton),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: SolvocaTokens.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: SolvocaTokens.onAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class SolvocaSecondaryButton extends StatelessWidget {
  const SolvocaSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(SolvocaTokens.radiusButton);
    final labelStyle = const TextStyle(
      fontFamily: SolvocaTokens.fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: SolvocaTokens.accent,
    );

    final button = SizedBox(
      height: SolvocaTokens.buttonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SolvocaTokens.surface,
          borderRadius: radius,
          border: Border.fromBorderSide(SolvocaTokens.secondaryBorder),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: icon == null
                    ? Text(label, style: labelStyle)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 20, color: SolvocaTokens.accent),
                          const SizedBox(width: 8),
                          Text(label, style: labelStyle),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

class SolvocaIconButton extends StatelessWidget {
  const SolvocaIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(SolvocaTokens.radiusButton),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: SolvocaTokens.textPrimary),
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }
    return Tooltip(message: tooltip!, child: button);
  }
}

class SolvocaTextAction extends StatelessWidget {
  const SolvocaTextAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tooltip,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      foregroundColor: SolvocaTokens.accent,
      textStyle: const TextStyle(
        fontFamily: SolvocaTokens.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
    final child = icon == null
        ? TextButton(onPressed: onPressed, style: style, child: Text(label))
        : TextButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon, size: 20),
            label: Text(label),
          );
    if (tooltip == null) {
      return child;
    }
    return Tooltip(message: tooltip!, child: child);
  }
}
