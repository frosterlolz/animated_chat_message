part of 'timestamped_chat_message.dart';

/// Simplified variant of [RenderParagraph] which supports the
/// [TimestampedChatMessage] widget.
///
/// Like the [Text] widget and its inner [RenderParagraph], the
/// [TimestampedChatMessageRenderObject] makes heavy use of the [TextPainter]
/// class.
class TimestampedChatMessageRenderObject extends RenderBox {
  TimestampedChatMessageRenderObject({
    required String message,
    required TextStyle messageTextStyle,
    required String sentAt,
    required TextStyle sentAtTextStyle,
    required String? sendingStatusIcon,
    required TextStyle? sendingStatusTextStyle,
    required TextDirection textDirection,
  }) {
    _textDirection = textDirection;
    _message = message;
    _messageTextStyle = messageTextStyle;
    _sentAt = sentAt;
    _sentAtTextStyle = sentAtTextStyle;
    _sendingStatusIcon = sendingStatusIcon;
    _sendingStatusTextStyle = sendingStatusTextStyle;

    _messageTextPainter = TextPainter(
      text: messageTextSpan,
      textDirection: _textDirection,
    );
    _sentAtTextPainter = TextPainter(
      text: sentAtTextSpan,
      textDirection: _textDirection,
    );
    _sendingStatusTextPainter = TextPainter(
      text: sendingStatusTextSpan,
      textDirection: _textDirection,
    );
  }

  /// message block
  late String _message;
  late TextStyle _messageTextStyle;
  late TextPainter _messageTextPainter;

  /// sent at block
  late String _sentAt;
  late TextStyle _sentAtTextStyle;
  late TextPainter _sentAtTextPainter;

  /// sending status block
  late String? _sendingStatusIcon;
  late TextStyle? _sendingStatusTextStyle;
  late TextPainter? _sendingStatusTextPainter;

  late TextDirection _textDirection;
  late bool _utilsFitsOnLastLine;
  late double _lineHeight;
  late double _lastMessageLineWidth;
  double _longestLineWidth = 0;
  late double _sentAtLineWidth;
  late double _sendingIconLineWidth;
  late int _numMessageLines;

  String? get sendingStatusIcon => _sendingStatusIcon;
  set sendingStatusIcon(String? val) {
    if (val == _sendingStatusIcon) return;
    _sendingStatusIcon = val;
    _sendingStatusTextPainter?.text = sendingStatusTextSpan;
    markNeedsLayout();
  }

  TextStyle? get sendingStatusTextStyle => _sendingStatusTextStyle;
  set sendingStatusTextStyle(TextStyle? val) {
    if (val == _sendingStatusTextStyle) return;
    _sendingStatusTextStyle = val;
    _sendingStatusTextPainter?.text = sendingStatusTextSpan;
    markNeedsLayout();
  }

  String get sentAt => _sentAt;
  set sentAt(String val) {
    if (val == _sentAt) return;
    _sentAt = val;
    _sentAtTextPainter.text = sentAtTextSpan;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  TextStyle get sentAtTextStyle => _sentAtTextStyle;
  set sentAtTextStyle(TextStyle val) {
    if (val == _sentAtTextStyle) return;
    _sentAtTextStyle = val;
    _sentAtTextPainter.text = sentAtTextSpan;
    markNeedsLayout();
  }

  String get message => _message;
  set message(String val) {
    if (val == _message) return;
    _message = val;
    _messageTextPainter.text = messageTextSpan;
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  TextStyle get messageTextStyle => _messageTextStyle;
  set messageTextStyle(TextStyle val) {
    if (val == _messageTextStyle) return;
    _messageTextStyle = val;
    _messageTextPainter.text = messageTextSpan;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection val) {
    if (_textDirection == val) {
      return;
    }
    _textDirection = val;
    _messageTextPainter.textDirection = val;
    _sentAtTextPainter.textDirection = val;
    markNeedsSemanticsUpdate();
    markNeedsLayout();
  }

  TextSpan get messageTextSpan =>
      TextSpan(text: _message, style: _messageTextStyle);
  TextSpan get sentAtTextSpan =>
      TextSpan(text: _sentAt, style: _sentAtTextStyle);
  TextSpan get sendingStatusTextSpan => TextSpan(
        text: _sendingStatusIcon,
        style: _sendingStatusTextStyle,
      );

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..isSemanticBoundary = true
      ..label = '$_message, sent $_sentAt'
      ..textDirection = _textDirection;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _layoutText(double.infinity);
    return _longestLineWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) {
    final computedSize = _layoutText(width);
    return computedSize.height;
  }

  @override
  void performLayout() {
    final unconstrainedSize = _layoutText(constraints.maxWidth);
    size = constraints.constrain(
      Size(unconstrainedSize.width, unconstrainedSize.height),
    );
  }

  /// Lays out the text within a given width constraint and returns its [Size].
  ///
  /// Because [_layoutText] is called from multiple places with multiple concerns,
  /// like intrinsics which could have different width parameters than a typical
  /// layout, this logic is moved out of `performLayout` and into a dedicated
  /// method which accepts and works with any width constraint.
  Size _layoutText(double maxWidth) {
    if (_messageTextPainter.text?.toPlainText() == '') {
      return Size.zero;
    }
    assert(
      maxWidth > 0,
      'You must allocate SOME space to layout a TimestampedChatMessageRenderObject. Received a '
      '`maxWidth` value of $maxWidth.',
    );

    // Layout the raw message, which saves expected high-level sizing values
    // to the painter itself.
    _messageTextPainter.layout(maxWidth: maxWidth);
    final textLines = _messageTextPainter.computeLineMetrics();

    // Now make similar calculations for `sentAt`.
    _sentAtTextPainter.layout(maxWidth: maxWidth);
    _sentAtLineWidth =
        _sentAtTextPainter.computeLineMetrics().firstOrNull?.width ?? 0.0;
    // And also make a similar calculation for `sendingStatus`.
    _sendingStatusTextPainter?.layout(maxWidth: maxWidth);
    _sendingIconLineWidth =
        _sendingStatusTextPainter?.computeLineMetrics().firstOrNull?.width ??
            0.0;

    // Reset cached values from the last frame if they're assumed to start at 0.
    // (Because this is used in `max`, if it opens a new frame still holding the
    // value from a previous frame, we could fail to accurately calculate the
    // longest line.)
    _longestLineWidth = 0;

    // Next, we calculate a few metrics for the height and width of the message.

    // First, chat messages don't actually grow to their full available width
    // if their longest line does not require it. Thus, we need to note the
    // longest line in the message.
    for (final line in textLines) {
      _longestLineWidth = math.max(_longestLineWidth, line.width);
    }
    // If the message is very short, it's possible that the longest line is
    // is actually the date.
    _longestLineWidth = math.max(_longestLineWidth, _sentAtTextPainter.width);

    // Because [_textPainter.width] can be the maximum width we passed to it,
    // even if the longest line is shorter, we use this logic to determine its
    // real size, for our purposes.
    final sizeOfMessage = Size(_longestLineWidth, _messageTextPainter.height);

    // Cache additional variables used both in the rest of this method and in
    // `paint` later on.
    _lastMessageLineWidth = textLines.last.width;
    _lineHeight = textLines.last.height;
    _numMessageLines = textLines.length;

    // Determine whether the message's last line and the date with status icon
    // (if it exists) can share a horizontal row together.
    final lastLineWithUtils = _lastMessageLineWidth +
        (_sentAtLineWidth + 5) +
        _sendingStatusSpacing +
        (_sendingIconLineWidth + 5);

    /// Value to allow for overlap while parent in animation
    const permissibleOverlap = 2.0;
    if (textLines.length == 1) {
      _utilsFitsOnLastLine = lastLineWithUtils <= maxWidth + permissibleOverlap;
    } else {
      _utilsFitsOnLastLine = lastLineWithUtils <=
          math.min(_longestLineWidth, maxWidth) + permissibleOverlap;
    }

    late Size computedSize;
    if (!_utilsFitsOnLastLine) {
      computedSize = Size(
        // If `sentAt` does not fit on the longest line, then we know the
        // message contains a long line, making this a safe value for `width`.
        sizeOfMessage.width,
        // And similarly, if `sentAt` does not fit, we know to add its height
        // to the overall size of just-the-message.
        sizeOfMessage.height + _sentAtTextPainter.height,
      );
    } else {
      // Moving forward, of course, we know that `sentAt` DOES fit into the last
      // line.

      if (textLines.length == 1) {
        computedSize = Size(
          // When there is only 1 line, our width calculations are in a special
          // case of needing as many pixels as our line plus the date, as opposed
          // to the full size of the longest line.
          lastLineWithUtils,
          sizeOfMessage.height,
        );
      } else {
        computedSize = Size(
          // But when there's more than 1 line, our width should be equal to the
          // longest line.
          _longestLineWidth,
          sizeOfMessage.height,
        );
      }
    }
    return computedSize;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Draw nothing (requiring no paint calls) if the string doesn't exist. This
    // is one of many opinionated choices we could make here if the text is empty.
    if (_messageTextPainter.text?.toPlainText() == '') {
      return;
    }

    // This line writes the actual message to the screen. Because we use the
    // same offset we were passed, the text will appear in the upper-left corner
    // of our available space.
    _messageTextPainter.paint(context.canvas, offset);

    late Offset sentAtOffset;
    late Offset sendingIconOffset;

    /// Ориентируемся на размер текста сообщения и выравниваем дату по нему
    final sizeDifference =
        (_messageTextStyle.fontSize ?? 1) - (_sentAtTextStyle.fontSize ?? 1);
    if (_utilsFitsOnLastLine) {
      sentAtOffset = Offset(
        offset.dx +
            (size.width -
                _sentAtLineWidth -
                _sendingIconLineWidth -
                _sendingStatusSpacing),
        offset.dy +
            _lineHeight * (_numMessageLines - 1) +
            sizeDifference +
            _kVerticalStatusOffset,
      );
      sendingIconOffset = Offset(
        offset.dx + (size.width - _sendingIconLineWidth),
        offset.dy +
            _lineHeight * (_numMessageLines - 1) +
            sizeDifference +
            _kVerticalStatusOffset,
      );
    } else {
      sentAtOffset = Offset(
        offset.dx + (size.width - _sentAtLineWidth - _sendingIconLineWidth),
        offset.dy + _lineHeight * _numMessageLines,
      );
      sendingIconOffset = Offset(
        offset.dx + (size.width - _sendingIconLineWidth),
        offset.dy + _lineHeight * _numMessageLines,
      );
    }

    // Finally, place the `sentAt` value accordingly.
    _sentAtTextPainter.paint(context.canvas, sentAtOffset);
    _sendingStatusTextPainter?.paint(context.canvas, sendingIconOffset);
  }
}
