part of 'animated_message_tile.dart';

class _StaticContextMenuView extends StatelessWidget {
  final List<CupertinoContextMenuAction> actions;
  final Rect childRect;
  final double bottomSpacing;
  final MenuAlignment alignment;
  final void Function(BuildContext context, Rect childRect) onDismiss;
  final GlobalKey childGlobalKey;
  final GlobalKey sheetGlobalKey;
  final Widget child;

  const _StaticContextMenuView({
    required this.actions,
    required this.bottomSpacing,
    required this.childRect,
    required this.alignment,
    required this.onDismiss,
    required this.childGlobalKey,
    required this.sheetGlobalKey,
    required this.child,
  });

  void _onDismiss(BuildContext context) {
    onDismiss.call(context, childRect);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _onDismiss(context),
        child: Padding(
          padding: EdgeInsets.only(
            left: switch (alignment) {
              MenuAlignment.left => childRect.left,
              MenuAlignment.right => 0,
            },
            right: switch (alignment) {
              MenuAlignment.left => 0.0,
              MenuAlignment.right =>
                MediaQuery.sizeOf(context).width - childRect.right,
            },
          ),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              children: [
                SizedBox(height: bottomSpacing),
                Align(
                  alignment: switch (alignment) {
                    MenuAlignment.left => Alignment.centerLeft,
                    MenuAlignment.right => Alignment.centerRight,
                  },
                  child: _AnimatedMessageActionsSheet(
                    key: sheetGlobalKey,
                    actions: actions,
                  ),
                ),
                const SizedBox(height: 10.0),
                Align(
                  alignment: switch (alignment) {
                    MenuAlignment.left => Alignment.centerLeft,
                    MenuAlignment.right => Alignment.centerRight,
                  },
                  child: SizedBox(
                    key: childGlobalKey,
                    width: childRect.width,
                    child: child,
                  ),
                ),
                const SizedBox(height: kToolbarHeight),
              ].reversed.toList(),
            ),
          ),
        ),
      );
}
