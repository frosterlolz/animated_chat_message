import 'package:flutter/cupertino.dart';

@immutable
class Message$Text {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isMyMessage;
  final SendingStatus status;
  final String text;

  const Message$Text({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isMyMessage,
    required this.status,
    required this.text,
  });

  DateTime get lastUpdated => updatedAt ?? createdAt;
  String get timeToShow =>
      '${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}';
  bool get canRemove => switch (status) {
        (SendingStatus.sent || SendingStatus.read) when isMyMessage => true,
        _ => false,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message$Text &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          isMyMessage == other.isMyMessage &&
          status == other.status &&
          text == other.text;

  @override
  int get hashCode => Object.hash(
        id,
        createdAt,
        updatedAt,
        isMyMessage,
        status,
        text,
      );
}

enum SendingStatus {
  pending,
  sent,
  read,
  failed,
}
