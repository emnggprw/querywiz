import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final bool isTyping;
  final Color dotColor;
  final Color backgroundColor;

  const TypingIndicator({
    Key? key,
    required this.isTyping,
    this.dotColor = Colors.cyanAccent,
    this.backgroundColor = Colors.grey,
  }) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _animControllers;
  final List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();

    _animControllers = List.generate(
        3,
            (index) => AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
        )
    );

    for (int i = 0; i < 3; i++) {
      _animations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animControllers[i],
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    }

    if (widget.isTyping) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isTyping != oldWidget.isTyping) {
      if (widget.isTyping) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  void _startAnimation() {
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) {
          _animControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimation() {
    for (var controller in _animControllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void dispose() {
    for (var controller in _animControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isTyping) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.backgroundColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 4),
          Text(
            'QueryWiz is typing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          ...List.generate(3, (index) => _buildDot(index)),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animControllers[index],
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 8 + (_animations[index].value * 4),
          width: 8 + (_animations[index].value * 4),
          decoration: BoxDecoration(
            color: widget.dotColor,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}