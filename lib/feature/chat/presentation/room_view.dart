import 'dart:math' as math;
import 'dart:math';

import 'package:animated_chat_message/feature/chat/model/message_model.dart';
import 'package:animated_chat_message/feature/chat/presentation/widget/message_tile.dart';
import 'package:animated_chat_message/feature/chat/utils/fake_messages.dart';
import 'package:flutter/material.dart';

const _primaryHorizontalSpacing = 16.0;

class RoomView extends StatefulWidget {
  const RoomView({super.key});

  @override
  State<RoomView> createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
  late final List<Message$Text> _messages;

  @override
  void initState() {
    super.initState();

    _messages = List.generate(
      40,
      (index) => Message$Text(
        id: index,
        createdAt: DateTime.now().add(Duration(hours: index)),
        updatedAt: index.isEven
            ? null
            : DateTime.now().add(Duration(hours: index - 1)),
        isMyMessage: index.isEven,
        status: SendingStatus.read,
        text: mockMessageS[Random().nextInt(mockMessageS.length)],
      ),
    ).reversed.toList();
  }

  void _onSendTap() => throw UnimplementedError('_onSendTap not implemented');

  void _onAttachTap() =>
      throw UnimplementedError('_onAttachTap not implemented');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey.shade200,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {},
            icon: Icon(Icons.adaptive.arrow_back),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Mr.Brown'),
              Text('Online', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        body: ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(
            left: _primaryHorizontalSpacing,
            right: _primaryHorizontalSpacing,
            bottom: _primaryHorizontalSpacing,
          ),
          itemCount: _messages.length,
          itemBuilder: (context, index) => MessageTile(
            message: _messages[index],
          ),
        ),
        bottomNavigationBar: ColoredBox(
          color: Colors.grey.shade200,
          child: Padding(
            padding: EdgeInsets.only(
              left: _primaryHorizontalSpacing / 2,
              right: _primaryHorizontalSpacing / 2,
              top: _primaryHorizontalSpacing / 4,
              bottom: MediaQuery.viewInsetsOf(context).bottom + 10,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Transform.rotate(
                    angle: math.pi / 4,
                    child: IconButton(
                      onPressed: _onAttachTap,
                      icon: const Icon(Icons.attach_file),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Message',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: _primaryHorizontalSpacing,
                          vertical: _primaryHorizontalSpacing / 2,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              16.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _onSendTap,
                    icon: const Icon(Icons.send),
                  )
                ],
              ),
            ),
          ),
        ),
      );
}
