import 'package:flutter/material.dart';
import 'package:venta_cuba/view/constants/Colors.dart';

// Reusable Scroll to Top Button Widget
class ScrollToTopButton extends StatefulWidget {
  final ScrollController scrollController;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const ScrollToTopButton({
    Key? key,
    required this.scrollController,
    this.backgroundColor,
    this.iconColor,
    this.size,
  }) : super(key: key);

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> {
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (widget.scrollController.hasClients) {
      if (widget.scrollController.offset >= 200) {
        if (!_showButton) {
          setState(() {
            _showButton = true;
          });
        }
      } else {
        if (_showButton) {
          setState(() {
            _showButton = false;
          });
        }
      }
    }
  }

  void _scrollToTop() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 20,
        right: 20,
        child: AnimatedOpacity(
          opacity: _showButton ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: _showButton
              ? Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: _scrollToTop,
                    backgroundColor:
                        widget.backgroundColor ?? AppColors.k0xFF0254B8,
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: widget.iconColor ??
                          Theme.of(context).colorScheme.onPrimary,
                      size: widget.size ?? 24,
                    ),
                    mini: true,
                    elevation: 4,
                  ),
                )
              : const SizedBox.shrink(),
        ));
  }
}
