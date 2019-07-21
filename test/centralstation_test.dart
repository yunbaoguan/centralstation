import 'package:centralstation/centralstation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Echo Command Definition
class EchoCommand {
  final String message;
  EchoCommand(this.message);
}

/// Echo Command Handler
Stream echo(dynamic command) async* {
  var cmd = command as EchoCommand;
  var resp = "Hello ${cmd.message}";

  // dispatch an echo event
  dispatchEvent(EchoEvent(cmd.message, resp));

  yield resp;
}

/// Echo Event Definition
class EchoEvent {
  final String message;
  final String response;
  EchoEvent(this.message, this.response);
}

/// Echo Event Handler
void eventHandler(event) {
  print("Echo Event: ${event.message} -> ${event.response}");
  echoResponse = event.response;
}

/// Simple value holder for test assertion
var echoResponse;

class TestAppWidget extends StatelessWidget {
  final btnKey;

  TestAppWidget(this.btnKey);

  final CentralStationRuntime runtime = CentralStationRuntime(
    commandHandlers: {
      EchoCommand: echo,
    },
    eventHandlers: [
      SimpleEventHandler(EchoEvent, eventHandler),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CentralStation(
        runtime: runtime,
        child: Builder(
          builder: (context) => RaisedButton(
            key: btnKey,
            child: Text("Execute Command"),
            onPressed: () async {
              var resp = await CentralStation.chain(context, EchoCommand("One"))
                  .then((s) => s == "Hello One", EchoCommand("Two"))
                  .then((s) => s == "XXX", EchoCommand("Three"),
                      failResult: "Bad!")
                  .done()
                  .first;
              print("Command Response: $resp");
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  final Key btn = Key("Button");

  testWidgets('Initialize CentralStation', (WidgetTester tester) async {
    // Create the widget by telling the tester to build it.
    await tester.pumpWidget(TestAppWidget(btn));
    assert(echoResponse == null);

    await tester.tap(find.byKey(btn));
    await tester.idle();

    assert(echoResponse == "Hello Two");
  });
}
