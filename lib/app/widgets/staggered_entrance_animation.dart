import 'package:flutter/material.dart';

class StaggeredEntranceAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset initialOffset; // e.g., Offset(0, 0.2) for slide up from bottom
  final Curve curve;

  const StaggeredEntranceAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 400),
    this.initialOffset = const Offset(0.0, 0.15), // Default: slide up slightly
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<StaggeredEntranceAnimation> createState() =>
      _StaggeredEntranceAnimationState();
}

class _StaggeredEntranceAnimationState extends State<StaggeredEntranceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation =
        Tween<Offset>(begin: widget.initialOffset, end: Offset.zero)
            .animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Start animation after the specified delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
