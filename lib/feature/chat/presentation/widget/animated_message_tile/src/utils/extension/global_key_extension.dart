import 'package:flutter/widgets.dart';

extension GlobalUtils on GlobalKey {
  Rect getRect() {
    assert(currentContext != null);
    final renderBoxContainer = currentContext!.findRenderObject()! as RenderBox;
    return Rect.fromPoints(
      renderBoxContainer.localToGlobal(
        renderBoxContainer.paintBounds.topLeft,
      ),
      renderBoxContainer
          .localToGlobal(renderBoxContainer.paintBounds.bottomRight),
    );

    // final renderObject =
    //     globalKey.currentContext!.findRenderObject() as RenderBox;
    // final translation = renderObject.getTransformTo(null).getTranslation();
    // final offset = Offset(translation.x, translation.y);
    // return renderObject.paintBounds.shift(offset);
  }

  Rect getScaledRect(double scale) {
    final Rect childRect = getRect();
    final Size sizeScaled = childRect.size * scale;
    final Offset offsetScaled = Offset(
      childRect.left + (childRect.size.width - sizeScaled.width) / 2,
      childRect.top + (childRect.size.height - sizeScaled.height) / 2,
    );
    return offsetScaled & sizeScaled;
  }
}
