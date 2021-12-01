import "package:centralstation/centralstation.dart";
import 'package:flutter/material.dart';

import 'command.dart';

class IPWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return IPWidgetState();
  }
}

class IPWidgetState extends State<IPWidget> {
  String ipAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Central Station Sample"),
      ),
      body: Builder(
        builder: (context) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(ipAddress ?? "Not Ready"),
              ElevatedButton(
                child: Text("Get IP"),
                onPressed: () {
                  setState(() {
                    this.ipAddress = null;
                  });
                  CentralStation.sendCommand(context, GetIPCommand(),
                          waitingText: "Getting Outbound IP Address...")
                      .first
                      .then((ip) {
                    setState(() {
                      this.ipAddress = ip;
                    });
                  });
                },
              )
            ],
          ));
        },
      ),
    );
  }
}
