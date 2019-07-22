import 'package:flutter/material.dart';

import "package:centralstation/centralstation.dart";
import 'command.dart';
import 'ip.dart';

void main() {
  CentralStationRuntime runtime = CentralStationRuntime(
    commandHandlers: {
      GetIPCommand: getIp,
    },
    eventHandlers: [],
  );

  runApp(MaterialApp(
    home: CentralStation(
      runtime: runtime,
      child: IPWidget(),
    ),
  ));
}
