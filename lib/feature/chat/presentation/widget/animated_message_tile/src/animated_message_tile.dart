import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'utils/utils.dart';

part 'animated_message_action_sheet.dart';
part 'context_menu_route.dart';
part 'static_context_menu_view.dart';

const Color _modalBarrierColor = Color(0x6604040F);

const _primaryDuration = Duration(milliseconds: 150);

/// value to reduce child height
const _primaryHeightReducer = 4.0;

class AnimatedMessageTile extends StatefulWidget {
  AnimatedMessageTile({
    required this.child,
    required this.actions,
    super.key,
  }) : assert(actions.isNotEmpty);

  final Widget child;
  final List<CupertinoContextMenuAction> actions;

  @override
  State<AnimatedMessageTile> createState() => _AnimatedMessageTileState();
}

class _AnimatedMessageTileState extends State<AnimatedMessageTile>
    with TickerProviderStateMixin<AnimatedMessageTile> {
  late bool _isShow;
  late final AnimationController _primaryController;
  late final Animation<double> _primaryAnimation;
  OverlayEntry? _childOverlay;
  late final GlobalKey _childGlobalKey;
  _ContextMenuRoute? _route;

  @override
  void initState() {
    super.initState();
    _childGlobalKey = GlobalKey();
    _isShow = true;
    _initPrimaryController();
  }

  Future<void> _initPrimaryController() async {
    _primaryController = AnimationController(
      vsync: this,
      duration: _primaryDuration,
    )..addStatusListener(_primaryAnimationStatusListener);
    final primaryScaleFactor = Completer<double>();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        if (_childGlobalKey.currentContext != null) {
          final childRect = _childGlobalKey.getRect();
          primaryScaleFactor.complete(
            (childRect.height - _primaryHeightReducer) / childRect.height,
          );
        }
      },
      debugLabel: 'calculateChildScaleFactor',
    );
    final endValue = await primaryScaleFactor.future;
    _primaryAnimation = Tween<double>(
      begin: 1,
      end: endValue.toDouble(),
    ).animate(_primaryController);
  }

  void _primaryAnimationStatusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        if (_route == null) {
          setState(() {
            _isShow = true;
          });
        }
        _disposeOverlay();
      case AnimationStatus.forward:
        break;
      case AnimationStatus.reverse:
        break;
      case AnimationStatus.completed:
        HapticFeedback.heavyImpact();

        /// open new route!!!
        _openContextMenu();

        /// remove overlay and reset controller
        SchedulerBinding.instance.addPostFrameCallback(
          (_) {
            _disposeOverlay();
            _primaryController.reset();
          },
          debugLabel: 'removeContextMenuDecoy',
        );
        break;
    }
  }

  void _routeAnimationStatusListener(AnimationStatus status) {
    if (!status.isDismissed) {
      return;
    }
    if (mounted) {
      setState(() {
        _isShow = true;
      });
    }
    _route!.animation!.removeStatusListener(_routeAnimationStatusListener);
    _route = null;
  }

  void _openContextMenu() {
    setState(() {
      _isShow = false;
    });

    /// need beginRect and endScale
    final childRect = _childGlobalKey.getRect();
    final screenSize = MediaQuery.sizeOf(context);
    final alignment = childRect.center.dx > screenSize.width / 2
        ? MenuAlignment.right
        : MenuAlignment.left;
    _route = _ContextMenuRoute(
      alignment: alignment,
      actions: widget.actions,
      barrierLabel: CupertinoLocalizations.of(context).menuDismissLabel,
      filter: ui.ImageFilter.blur(
        sigmaX: 10.0,
        sigmaY: 10.0,
      ),
      childRect: _childGlobalKey.getRect(),
      initialScale: _primaryAnimation.value,
      child: widget.child,
    );
    Navigator.of(context, rootNavigator: true).push<void>(_route!);
    _route!.animation!.addStatusListener(_routeAnimationStatusListener);
  }

  void _disposeOverlay() {
    _childOverlay?.remove();
    _childOverlay?.dispose();
    _childOverlay = null;
  }

  void _onTapDown(TapDownDetails details) {
    final beginRect = _childGlobalKey.getRect();

    /// hide source widget
    setState(() {
      _isShow = false;
    });

    /// spawn overlay -> copy of source widget
    _childOverlay = OverlayEntry(
      builder: (context) => _ScalingChildWidget(
        beginRect: beginRect,
        sourceChild: widget.child,
        primaryAnimation: _primaryAnimation,
      ),
    );
    Overlay.of(context).insert(_childOverlay!);

    /// start animation
    _primaryController.forward();
  }

  void _onTapUp(TapUpDetails details) => _onTapCancel();

  void _onTapCancel() {
    if (!_primaryController.isAnimating) return;
    _primaryController.reverse();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Visibility.maintain(
          key: _childGlobalKey,
          visible: _isShow,
          child: widget.child,
        ),
      );
}

class _ScalingChildWidget extends StatelessWidget {
  const _ScalingChildWidget({
    required this.beginRect,
    required this.sourceChild,
    required this.primaryAnimation,
  });

  final Rect beginRect;
  final Widget sourceChild;
  final Animation<double> primaryAnimation;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned.fromRect(
            rect: beginRect,
            child: AnimatedBuilder(
              animation: primaryAnimation,
              builder: (context, child) => Transform.scale(
                scale: primaryAnimation.value,
                child: child,
              ),
              child: sourceChild,
            ),
          ),
        ],
      );
}
