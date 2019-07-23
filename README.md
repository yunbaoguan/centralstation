# Central Station

[![pub package](https://img.shields.io/pub/v/centralstation.svg)](https://pub.dartlang.org/packages/centralstation)

Central Station is a simple Command / Event Processing engine for Flutter.

## Introduction

### What is a Command?

* A *Command* is some sequence of program steps to run that will make state changes.
* A Command is something we want to happen
* A Command executed may produce a result
* Example: "Make a network request to get a stock quote for code X."

### What is an Event?

* An *Event* represents something that has happened.
* An *Event* is an evidence of some state change.
* Example: "A stock quote of code X is obtained with stock price Y."

### Characteristics

* A command generally needs more time to execute
* A command may raise some events which should be notified to other components to display or to keep track of
* A command may fail during execution
* A single command would have a single processor to process that command
* A single event can be listened by multiple components

## Getting Started

Suppose we have a get stock quote command and corresponding event:

```dart
class GetStockQuoteCommand {
  final String code;
  GetStockQuoteCommand(this.code);
}

class StockQuoteObtainedEvent {
  final String code;
  final num price;
  StockQuoteObtainedEvent(this.code, this.price);
}

/// Implementation
Stream getStockQuote(dynamic command) async* {
  var cmd = command as GetStockQuoteCommand;
  num price = await ... // do some network operations;

  dispatchEvent(StockQuoteObtainedEvent(cmd.code, price)); // notify others

  yield price; // command result
}
```

To use Central Station, first initialze the runtime.

```dart
  final CentralStationRuntime runtime = CentralStationRuntime(
    commandHandlers: {
      GetStockQuoteCommand: getStockQuote,
    },
    eventHandlers: [],  // set this if you have event handlers
  );
```

Initialize CentralStation during widget construction.

```dart
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CentralStation(
        runtime: runtime,
        child: ... /// build your own widget as usual
        ),
      ),
    );
  }
```

To execute a command at some point, do as follows:

```dart
    RaisedButton(
        key: btnKey,
        child: Text("Get Quote!"),
        onPressed: () async {
            var stockPrice = await CentralStation.sendCommand(context, GetStockQuoteCommand(this.code)).first;
            setState(() {
                // UI changes
                this.price = stockPrice;
            });
        },
    ),
```

There are some other interesting features like chaining commands, 
showing waiting text, etc.

In one production project, I have used Central Station with BLOC pattern (using event handlers to bridge events to BLOC dispatch method) which make the project quite easy to manage.

Feel free to explore other possibilities and I would be glad to hear any feedbacks.


### Further Reading

* CQRS: https://martinfowler.com/bliki/CQRS.html
* CQRS and Event Sourcing Concepts: https://axoniq.io/resources/concepts
* BLOC Pattern: https://medium.com/flutterpub/architecting-your-flutter-project-bd04e144a8f1 
