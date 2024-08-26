import 'package:animated_chat_message/feature/chat/model/message_model.dart';
import 'package:animated_chat_message/feature/chat/presentation/widget/animated_message_tile/animated_message_tile.dart';
import 'package:animated_chat_message/feature/chat/presentation/widget/timestamped_chat_message/src/timestamped_chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _primaryVerticalSpacing = 4.0;
const _primaryHorizontalSpacing = 80.0;
const _contentSpacing = 8.0;

class MessageTile extends StatelessWidget {
  const MessageTile({
    required this.message,
    super.key,
  });

  final Message$Text message;

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: message.text));
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied'),
      ),
    );
    // final a = CupertinoContextMenu(actions: actions, child: child)''
  }

  void _cancelSending() =>
      throw UnimplementedError('_cancelSending not implemented');
  void _remove() => throw UnimplementedError('_remove not implemented');
  void _select() => throw UnimplementedError('_select not implemented');

  @override
  Widget build(BuildContext context) => Align(
        alignment:
            message.isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(
            top: _primaryVerticalSpacing,
            bottom: _primaryVerticalSpacing,
            right: message.isMyMessage ? 0 : _primaryHorizontalSpacing,
            left: message.isMyMessage ? _primaryHorizontalSpacing : 0,
          ),
          child: AnimatedMessageTile(
            actions: [
              CupertinoContextMenuAction(
                onPressed: () => _copy(context),
                child: const Text('Copy'),
              ),
              if (message.status == SendingStatus.pending)
                CupertinoContextMenuAction(
                  onPressed: _cancelSending,
                  child: const Text('Cancel sending'),
                ),
              if (message.canRemove)
                CupertinoContextMenuAction(
                  onPressed: _remove,
                  isDestructiveAction: true,
                  child: const Text('Remove'),
                ),
              CupertinoContextMenuAction(
                onPressed: _select,
                child: const Text('Select'),
              ),
            ],
            child: Material(
              color: message.isMyMessage ? Colors.greenAccent : Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: Padding(
                padding: const EdgeInsets.all(_contentSpacing),
                child: TimestampedChatMessage(
                  message: message.text,
                  sentAt: message.timeToShow,
                  sendingStatusIcon: switch (message.status) {
                    _ when !message.isMyMessage => null,
                    SendingStatus.pending => const Icon(Icons.pending_outlined),
                    SendingStatus.sent => const Icon(Icons.done),
                    SendingStatus.read => const Icon(Icons.done_all),
                    SendingStatus.failed => const Icon(Icons.error),
                  },
                ),
              ),
            ),
          ),
        ),
      );
}
