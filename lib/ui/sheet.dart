import 'package:flutter/material.dart';
import 'package:solvoca/ui/tokens.dart';

Future<T?> showSolvocaSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: SolvocaTokens.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SolvocaTokens.radiusSheet),
            ),
          ),
          child: builder(context),
        ),
      );
    },
  );
}

class SolvocaSheetBody extends StatelessWidget {
  const SolvocaSheetBody({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: SolvocaTokens.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontFamily: SolvocaTokens.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: SolvocaTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
