part of 'animated_message_tile.dart';

const double _kMenuWidth = 250.0;
const Color _borderColor = CupertinoDynamicColor.withBrightness(
  color: Color(0xFFA9A9AF),
  darkColor: Color(0xFF57585A),
);

class _AnimatedMessageActionsSheet extends StatelessWidget {
  const _AnimatedMessageActionsSheet({
    required this.actions,
    super.key,
  });

  final List<CupertinoContextMenuAction> actions;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: _kMenuWidth,
        child: IntrinsicHeight(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(13.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                actions.first,
                for (final Widget action in actions.skip(1))
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: CupertinoDynamicColor.resolve(
                            _borderColor,
                            context,
                          ),
                          width: 0.4,
                        ),
                      ),
                    ),
                    position: DecorationPosition.foreground,
                    child: action,
                  ),
              ],
            ),
          ),
        ),
      );
}
