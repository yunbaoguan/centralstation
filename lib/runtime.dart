import 'package:event_bus/event_bus.dart';

/// register event handler to runtime
abstract class EventHandler {
  bool canHandle(dynamic event);
  void handle(dynamic event);
}

/// command handler definition, should return a stream
typedef Stream CommandHandler(dynamic command);

/// global event bus
EventBus _eventBus = EventBus();

/// exposed as public event sending point
dispatchEvent(dynamic event) {
  _eventBus.fire(event);
}

class CentralStationRuntime {
  final List<EventHandler> eventHandlers;
  final Map<Type, CommandHandler> commandHandlers;

  CentralStationRuntime({
    required this.commandHandlers,
    required this.eventHandlers,
  }) {
    // for event dispatching
    _eventBus.on().listen((event) {
      _dispatch(event);
    });
  }

  Stream send(dynamic command) {
    var type = command.runtimeType;
    var handler = commandHandlers[type];
    if (handler == null) {
      throw "No command handler for type: $type";
    }
    return handler(command);
  }

  void _dispatch(dynamic event) {
    eventHandlers
        .where((eh) => eh.canHandle(event))
        .forEach((eh) => eh.handle(event));
  }
}

/// Event Handler Function
typedef void EventHandlerFunc(dynamic event);

/// Simple Event Handler (Type/Handler)
class SimpleEventHandler extends EventHandler {
  final Type type;
  final EventHandlerFunc handler;
  SimpleEventHandler(this.type, this.handler);

  @override
  bool canHandle(event) {
    return event.runtimeType == type;
  }

  @override
  void handle(event) {
    handler(event);
  }
}
