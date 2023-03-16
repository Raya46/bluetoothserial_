import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothCon extends StatelessWidget {
  const BluetoothCon({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
          child: Container(
              child: RawMaterialButton(
            onPressed: () {
              FlutterBluetoothSerial.instance.openSettings();
            },
            elevation: 0,
            fillColor: Color.fromRGBO(42, 50, 75, 1),
            child: Icon(
              Icons.bluetooth,
              color: Color.fromRGBO(225, 229, 238, 1),
              size: (constraints.maxWidth * 0.3),
            ),
            padding: EdgeInsets.all(constraints.maxWidth * 0.1),
            shape: CircleBorder(),
          )),
        
      );
    });
  }
}