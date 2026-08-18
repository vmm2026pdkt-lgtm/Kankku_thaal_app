import 'package:flutter/material.dart';
import '../utils/helpers.dart';

/// AnimatedAmount — smoothly counts up/down to the target rupee value
/// whenever it changes, giving summary numbers a premium, alive feel.
class AnimatedAmount extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final String prefix;
  final Duration duration;

  const AnimatedAmount({
    super.key,
    required this.amount,
    this.style,
    this.prefix = '',
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text('$prefix${AppHelpers.formatCurrency(value)}', style: style);
      },
    );
  }
}
