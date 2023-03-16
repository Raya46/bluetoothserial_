import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothManager {
  static BluetoothConnection? connection;

  static Future<bool> connect(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address)
          .then((_connection) {
        print(_connection);
        connection = _connection;
        return connection;
      });
      return true;
    } catch (ex) {
      print(ex);
      return false;
    }
  }

  static sendData(String data) async {
    if (connection != null) {
      try {
        connection?.output.add(Uint8List.fromList(utf8.encode(data)));
        await connection?.output.allSent;
      } catch (ex) {
        print(ex);
      }
    }
  }

  static void disconnect() async {
    if (connection != null) {
      await connection?.close();
      connection = null;
    }
  }
}
