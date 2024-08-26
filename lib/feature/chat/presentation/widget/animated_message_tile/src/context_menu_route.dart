part of 'animated_message_tile.dart';

const Duration _modalPopupTransitionDuration = Duration(milliseconds: 250);

class _ContextMenuRoute extends PopupRoute<void> {
  _ContextMenuRoute({
    required this.barrierLabel,
    required Rect childRect,
    required double initialScale,
    required this.child,
    required this.actions,
    super.filter,
    required MenuAlignment alignment,
  })  : _alignment = alignment,
        _previousChildRect = childRect,
        _bottomSpacing = 0.0,
        _scale = initialScale,
        _sheetRect = Rect.fromLTWH(
          childRect.left,
          childRect.bottom + 10.0,
          0,
          0,
        );

  @override
  final String? barrierLabel;
  final Rect _previousChildRect;
  double _scale;
  final Widget child;
  final List<CupertinoContextMenuAction> actions;

  final GlobalKey _childGlobalKey = GlobalKey();
  final MenuAlignment _alignment;
  bool _externalOffstage = false;
  bool _internalOffstage = false;
  final GlobalKey _sheetGlobalKey = GlobalKey();
  Rect _sheetRect;
  double _bottomSpacing;
  final RectTween _childRectTween = RectTween();

  @override
  Color? get barrierColor => _modalBarrierColor;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => _modalPopupTransitionDuration;

  void _onDismiss(BuildContext context, Rect startRect) {
    _scale = 1.0;
    _childRectTween.end = _childGlobalKey.getRect();
    Navigator.of(context).pop();
  }

  void _updateTweenRects([Rect? childEndRect]) {
    _childRectTween.begin = _previousChildRect;
    final screenSize = MediaQuery.sizeOf(_childGlobalKey.currentContext!);

    _sheetRect = _sheetGlobalKey.getRect();
    final topSpacing = _translationY(
      screenHeight: screenSize.height,
      sheetHeight: _sheetRect.height,
    );
    _childRectTween.end =
        childEndRect ?? _previousChildRect.translate(0.0, topSpacing);
  }

  void _setOffstageInternally() {
    super.offstage = _externalOffstage || _internalOffstage;
    // It's necessary to call changedInternalState to get the backdrop to
    // update.
    changedInternalState();
  }

  @override
  TickerFuture didPush() {
    _internalOffstage = true;
    _setOffstageInternally();

    SchedulerBinding.instance.addPostFrameCallback((Duration _) {
      _updateTweenRects();
      _internalOffstage = false;
      _setOffstageInternally();
    }, debugLabel: 'renderContextMenuRouteOffstage');
    return super.didPush();
  }

  @override
  bool didPop(void result) {
    // _updateTweenRects();
    return super.didPop(result);
  }

  @override
  set offstage(bool value) {
    _externalOffstage = value;
    _setOffstageInternally();
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget _,
  ) {
    if (!animation.isCompleted) {
      final screenSize = MediaQuery.sizeOf(context);

      final childScale =
          Tween<double>(begin: _scale, end: 1.0).evaluate(animation);
      final sheetScale =
          Tween<double>(begin: 0.0, end: 1.0).evaluate(animation);
      final childRectTween = _childRectTween.evaluate(animation)!;

      return Stack(
        children: [
          Positioned.fromRect(
            key: _childGlobalKey,
            rect: childRectTween,
            child: ScaleTransition(
              scale: AlwaysStoppedAnimation(childScale),
              child: child,
            ),
          ),
          Positioned(
            top: childRectTween.top + childRectTween.height + 10,
            left: switch (_alignment) {
              MenuAlignment.left => childRectTween.left,
              MenuAlignment.right => null,
            },
            right: switch (_alignment) {
              MenuAlignment.left => null,
              MenuAlignment.right => screenSize.width - childRectTween.right,
            },
            child: ScaleTransition(
              alignment: switch (_alignment) {
                MenuAlignment.left => Alignment.topLeft,
                MenuAlignment.right => Alignment.topRight,
              },
              scale: AlwaysStoppedAnimation(sheetScale),
              child: _AnimatedMessageActionsSheet(
                actions: actions,
                key: _sheetGlobalKey,
              ),
            ),
          ),
        ],
      );
    }

    return _StaticContextMenuView(
      actions: actions,
      alignment: _alignment,
      childRect: _previousChildRect,
      bottomSpacing: _bottomSpacing,
      onDismiss: _onDismiss,
      childGlobalKey: _childGlobalKey,
      sheetGlobalKey: _sheetGlobalKey,
      child: child,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      const SizedBox.shrink();

  double _translationY({
    required double screenHeight,
    required double sheetHeight,
  }) {
    /// Calculate bottom position
    final visibleCompositionHeight =
        _previousChildRect.bottom + 10.0 + sheetHeight;

    /// Get overflow based on bottom position and screen height
    final overflowDifference = screenHeight - visibleCompositionHeight;

    final needToTranslate = overflowDifference < kBottomNavigationBarHeight;

    final outputAlignment = needToTranslate
        ? -(kBottomNavigationBarHeight - overflowDifference)
        : 0.0;

    _calculateBottomSpacing(
      screenHeight - (visibleCompositionHeight + outputAlignment),
    );

    return outputAlignment;
  }

  void _calculateBottomSpacing(double incomingBottomSpacing) {
    _bottomSpacing = max(kBottomNavigationBarHeight, incomingBottomSpacing);
    print('BOTTOM SPACING: $_bottomSpacing');
  }
}
