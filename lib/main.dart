import 'dart:async';

import 'package:animated_chat_message/feature/chat/presentation/room_view.dart';
import 'package:flutter/material.dart';

void main() => runZonedGuarded(
      () => runApp(const App()),
      (e, s) {
        debugPrint('$e');
        debugPrintStack(stackTrace: s);
      },
    );

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: Colors.green,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.blueGrey.shade200,
        ),
        home: const RoomView(),
      );
}
