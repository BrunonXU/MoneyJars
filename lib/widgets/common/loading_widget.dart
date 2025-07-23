import 'package:flutter/material.dart';
import '../../config/constants.dart';

class LoadingWidget extends StatefulWidget {
  final String? message;
  final Color? color;
  final double size;

  const LoadingWidget({
    Key? key,
    this.message,
    this.color,
    this.size = 50.0,
  }) : super(key: key);

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: AppConstants.curveDefault),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _animation,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color ?? AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                boxShadow: AppConstants.shadowMedium,
              ),
              child: Icon(
                Icons.savings,
                size: widget.size * 0.5,
                color: AppConstants.cardColor,
              ),
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              widget.message!,
              style: AppConstants.bodyStyle.copyWith(
                color: widget.color ?? AppConstants.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  const LoadingOverlay({
    Key? key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: LoadingWidget(message: loadingMessage),
          ),
      ],
    );
  }
} 