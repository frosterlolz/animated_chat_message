import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

part 'timestamped_chat_message_render_object.dart';

const _kVerticalStatusOffset = 3.0;
const _sendingStatusSpacing = 4.0;

/// The [TimestampedChatMessage] extends [LeafRenderObjectWidget], which means
/// it has no children and instead creates a [TimestampedChatMessageRenderObject],
/// which handles all layout and painting itself.
class TimestampedChatMessage extends LeafRenderObjectWidget {
  const TimestampedChatMessage({
    super.key,
    required this.message,
    required this.sentAt,
    this.style,
    this.sendAtStyle,
    this.sendingStatusIcon,
    this.sendingStatusIconColor,
    this.onSendingStatusTap,
  });

  final String message;
  final String sentAt;
  final TextStyle? style;
  final TextStyle? sendAtStyle;
  final Icon? sendingStatusIcon;
  final Color? sendingStatusIconColor;
  final VoidCallback? onSendingStatusTap;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);

    /// Configure message text textStyle
    var effectiveMessageTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveMessageTextStyle = defaultTextStyle.style.merge(style);
    }

    /// Configure sendAt textStyle
    var effectiveSendAtStyle = sendAtStyle;
    if (sendAtStyle == null || sendAtStyle!.inherit) {
      effectiveSendAtStyle = defaultTextStyle.style
          .copyWith(
            fontSize: 13,
            color: (effectiveSendAtStyle ?? defaultTextStyle.style)
                .color!
                .withAlpha(100),
          )
          .merge(sendAtStyle);
    }

    /// Configure sendingStatus icon textStyle
    final effectiveSendingStatusIconStyle = sendingStatusIcon == null
        ? null
        : effectiveSendAtStyle!.copyWith(
            color: sendingStatusIconColor ?? defaultTextStyle.style.color,
            shadows: sendingStatusIcon!.shadows,
            fontSize: sendingStatusIcon!.size,
            fontFamily: sendingStatusIcon!.icon!.fontFamily,
            package: sendingStatusIcon!.icon!.fontPackage,
          );
    return TimestampedChatMessageRenderObject(
      message: message,
      sentAt: sentAt,
      sendingStatusIcon: sendingStatusIcon == null
          ? null
          : String.fromCharCode(sendingStatusIcon!.icon!.codePoint),
      messageTextStyle: effectiveMessageTextStyle!,
      sentAtTextStyle: effectiveSendAtStyle!,
      sendingStatusTextStyle: effectiveSendingStatusIconStyle,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    TimestampedChatMessageRenderObject renderObject,
  ) {
    final defaultTextStyle = DefaultTextStyle.of(context);

    /// Configure message text textStyle
    var effectiveMessageTextStyle = style;
    if (style == null || style!.inherit) {
      effectiveMessageTextStyle = defaultTextStyle.style.merge(style);
    }

    /// Configure sendAt textStyle
    var effectiveSendAtStyle = sendAtStyle;
    if (sendAtStyle == null || sendAtStyle!.inherit) {
      effectiveSendAtStyle = defaultTextStyle.style
          .copyWith(
            fontSize: 13,
            color: (effectiveSendAtStyle ?? defaultTextStyle.style)
                .color!
                .withAlpha(100),
          )
          .merge(sendAtStyle);
    }

    /// Configure sendingStatus icon textStyle
    final effectiveSendingStatusIconStyle = sendingStatusIcon == null
        ? null
        : effectiveSendAtStyle!.copyWith(
            color: sendingStatusIconColor ?? defaultTextStyle.style.color,
            shadows: sendingStatusIcon!.shadows,
            fontSize: sendingStatusIcon!.size,
            fontFamily: sendingStatusIcon!.icon!.fontFamily,
            package: sendingStatusIcon!.icon!.fontPackage,
          );

    renderObject
      ..message = message
      ..sentAt = sentAt
      ..sendingStatusIcon = sendingStatusIcon == null
          ? null
          : String.fromCharCode(sendingStatusIcon!.icon!.codePoint)
      ..messageTextStyle = effectiveMessageTextStyle!
      ..sentAtTextStyle = effectiveSendAtStyle!
      ..sendingStatusTextStyle = effectiveSendingStatusIconStyle
      ..textDirection = Directionality.of(context);
  }
}
