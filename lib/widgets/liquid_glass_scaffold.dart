import 'dart:ui';
import 'package:flutter/material.dart';

/// A scaffold where body content extends under the app bar and optional
/// floating glass panels, with glass floating on top.
///
/// Uses a Stack so the body fills the entire screen while the app bar
/// and bottom bar remain transparent glass layers.
class LiquidGlassScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  const LiquidGlassScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.transparent,
      extendBodyBehindAppBar: appBar != null,
      extendBody: bottomNavigationBar != null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: body),
          if (appBar != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: appBar!,
            ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar != null
          ? ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.12),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: bottomNavigationBar!,
            ),
          ),
        ),
      )
          : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
