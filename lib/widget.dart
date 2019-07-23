import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'runtime.dart';

/// future is completed when the waiting dialog is being closed (cancellation?)
typedef Future WaitingHandler(BuildContext context, String text);
typedef void DismissWaitingHandler(BuildContext context);
typedef void ErrorHandler(BuildContext context, dynamic error);

class CentralStation extends InheritedWidget {
  final CentralStationRuntime runtime;
  final WaitingHandler showWaiting;
  final DismissWaitingHandler dismissWaiting;
  final ErrorHandler showErrorHandler;

  const CentralStation({
    Key key,
    @required this.runtime,
    @required Widget child,
    this.showWaiting = _buildWaiting,
    this.showErrorHandler = _showError,
    this.dismissWaiting = _dismissWaitingHandler,
  })  : assert(runtime != null),
        assert(child != null),
        super(key: key, child: child);

  static CentralStation of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(CentralStation)
        as CentralStation;
  }

  static Stream sendCommand(BuildContext context, cmd, {String waitingText}) {
    return CentralStation.of(context)
        .send(context, cmd, waitingText: waitingText);
  }

  static ChainCommandContext chain(BuildContext context, cmd,
      {String waitingText}) {
    return ChainCommandContext(
      CentralStation.of(context),
      context,
      cmd,
      waitingText: waitingText,
    );
  }

  @override
  bool updateShouldNotify(CentralStation old) => runtime != old.runtime;

  Stream send(BuildContext context, dynamic command, {String waitingText}) {
    if (context != null) {
      bool closed = false;
      showWaiting(context, waitingText).asStream().listen((_) {
        // mark waiting dialog is already closed
        closed = true;
      });
      Stream st;
      try {
        st = runtime.send(command).asBroadcastStream();
      } catch (err) {
        _tryDismissWaiting(context, alreadyClosed: closed);
        showErrorHandler(context, err);
      }
      st.first.then((_) {
        _tryDismissWaiting(context, alreadyClosed: closed);
      }).catchError((err) {
        _tryDismissWaiting(context, alreadyClosed: closed);
        showErrorHandler(context, err);
      });
      // maybe null for no handler
      return st;
    } else {
      return runtime.send(command);
    }
  }

  void _tryDismissWaiting(BuildContext context, {bool alreadyClosed = false}) {
    if (!alreadyClosed) {
      dismissWaiting(context);
    }
  }
}

class ChainCommandContext {
  final CentralStation centralStation;
  final BuildContext context;
  final String waitingText;
  final ChainCommandContext parent;
  final Function test;
  final dynamic command;
  final dynamic failResult;
  ChainCommandContext(
    this.centralStation,
    this.context,
    this.command, {
    this.waitingText,
    this.parent,
    this.test,
    this.failResult,
  });

  ChainCommandContext then(Function test, dynamic command,
      {dynamic failResult}) {
    return ChainCommandContext(
      centralStation,
      context,
      command,
      waitingText: waitingText,
      parent: this,
      test: test,
      failResult: failResult,
    );
  }

  Stream done() async* {
    if (parent != null) {
      var parentResult = await parent.done().first;
      if (test == null || test(parentResult)) {
        var result = await centralStation
            .send(context, command, waitingText: waitingText)
            .first;
        yield result;
      } else {
        yield failResult;
      }
    } else {
      var result = await centralStation
          .send(context, command, waitingText: waitingText)
          .first;
      yield result;
    }
  }
}

/// default waiting to show a circular progress
Future _buildWaiting(BuildContext context, String text) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _WaitingDialog(text),
  );
}

/// pop to dismiss waiting dialog
void _dismissWaitingHandler(BuildContext context) {
  Navigator.of(context).pop();
}

/// default show alert dialog for errors
Future _showError(BuildContext context, err) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Text(err != null ? "$err" : ""),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

/// default waiting dialog implementation
class _WaitingDialog extends StatelessWidget {
  final String text;

  _WaitingDialog(this.text);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
        width: 200.0,
        height: 150.0,
        alignment: AlignmentDirectional.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircularProgressIndicator(),
            this.text != null ? Text(this.text) : Container(),
          ],
        ),
      ),
    );
  }
}
