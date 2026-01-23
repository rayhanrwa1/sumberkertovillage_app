import 'package:flutter/material.dart';

enum TSnackbarType { success, error, warning, info }

/// Global Snackbar helper
class TSnackbar {
  static OverlayEntry? _currentSnackBar;

  static void show(
    BuildContext context, {
    required String message,
    TSnackbarType type = TSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    hide();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TSnackbarWidget(
        message: message,
        type: type,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: () {
          overlayEntry.remove();
          _currentSnackBar = null;
        },
      ),
    );

    _currentSnackBar = overlayEntry;
    overlay.insert(overlayEntry);
  }

  static void hide() {
    _currentSnackBar?.remove();
    _currentSnackBar = null;
  }
}

// This UI Snackbar
class _TSnackbarWidget extends StatefulWidget {
  final String message;
  final TSnackbarType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _TSnackbarWidget({
    required this.message,
    required this.type,
    required this.duration,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
  });

  @override
  State<_TSnackbarWidget> createState() => _TSnackbarWidgetState();
}

class _TSnackbarWidgetState extends State<_TSnackbarWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _progressAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(_progressController);

    _slideController.forward();
    _progressController.forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    _progressController.stop();
    await _slideController.reverse();
    widget.onDismiss();
  }

  Color _backgroundColor() {
    switch (widget.type) {
      case TSnackbarType.success:
        return const Color(0xFF10B981);
      case TSnackbarType.error:
        return const Color(0xFFEF4444);
      case TSnackbarType.warning:
        return const Color(0xFFF59E0B);
      case TSnackbarType.info:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _icon() {
    switch (widget.type) {
      case TSnackbarType.success:
        return Icons.check_circle;
      case TSnackbarType.error:
        return Icons.error;
      case TSnackbarType.warning:
        return Icons.warning;
      case TSnackbarType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: _backgroundColor(),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _backgroundColor().withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(_icon(), color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (widget.actionLabel != null &&
                            widget.onAction != null)
                          TextButton(
                            onPressed: () {
                              widget.onAction!();
                              _dismiss();
                            },
                            child: Text(
                              widget.actionLabel!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        GestureDetector(
                          onTap: _dismiss,
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 2,
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

// Extension Api for message
extension TSnackbarExtension on BuildContext {
  void showSuccessSnackBar(String message) =>
      TSnackbar.show(this, message: message, type: TSnackbarType.success);

  void showErrorSnackBar(String message) =>
      TSnackbar.show(this, message: message, type: TSnackbarType.error);

  void showWarningSnackBar(String message) =>
      TSnackbar.show(this, message: message, type: TSnackbarType.warning);

  void showInfoSnackBar(String message) =>
      TSnackbar.show(this, message: message, type: TSnackbarType.info);
}
