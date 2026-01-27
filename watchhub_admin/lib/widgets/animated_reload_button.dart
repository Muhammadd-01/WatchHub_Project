// =============================================================================
// FILE: animated_reload_button.dart
// PURPOSE: Animated reload button with rotation
// =============================================================================

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AnimatedReloadButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const AnimatedReloadButton({
    super.key,
    required this.onPressed,
    this.color,
    this.size = 24,
  });

  @override
  State<AnimatedReloadButton> createState() => _AnimatedReloadButtonState();
}

class _AnimatedReloadButtonState extends State<AnimatedReloadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() {
    _controller.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: RotationTransition(
        turns: _animation,
        child: Icon(
          Icons.refresh,
          color: widget.color ?? AppColors.primaryGold,
          size: widget.size,
        ),
      ),
      onPressed: _handlePressed,
      tooltip: 'Refresh',
    );
  }
}
