import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:isoja_application/page/selectbonded.dart';
import 'package:isoja_application/page/ScanPage.dart';

// import './helpers/LineChart.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPage createState() => new _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  // BackgroundCollectingTask? _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();
    try {
      FlutterBluetoothSerial.instance.state.then((state) {
        setState(() {
          _bluetoothState = state;
        });
      });

      Future.doWhile(() async {
        // Wait if adapter not enabled
        if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
          return false;
        }
        await Future.delayed(Duration(milliseconds: 0xDD));
        return true;
      }).then((_) {
        // Update the address field
        FlutterBluetoothSerial.instance.address.then((address) {
          setState(() {
            _address = address!;
          });
        });
      });

      FlutterBluetoothSerial.instance.name.then((name) {
        setState(() {
          _name = name!;
        });
      });

      // Listen for futher state changes
      FlutterBluetoothSerial.instance
          .onStateChanged()
          .listen((BluetoothState state) {
        setState(() {
          _bluetoothState = state;
          _discoverableTimeoutTimer = null;
          _discoverableTimeoutSecondsLeft = 0;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    try {
      FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
      _discoverableTimeoutTimer?.cancel();
      super.dispose();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Bluetooth Serial'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            SwitchListTile(
              title: const Text('Enable Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                try {
                  future() async {
                    if (value)
                      await FlutterBluetoothSerial.instance.requestEnable();
                    else
                      await FlutterBluetoothSerial.instance.requestDisable();
                  }

                  future().then((_) {
                    setState(() {});
                  });
                } catch (e) {
                  print(e);
                }
              },
            ),
            ListTile(
              title: const Text('Bluetooth status'),
              subtitle: Text(_bluetoothState.toString()),
              trailing: ElevatedButton(
                child: const Text('Settings'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            ListTile(
              title: const Text('Local adapter address'),
              subtitle: Text(_address),
            ),
            ListTile(
              title: const Text('Local adapter name'),
              subtitle: Text(_name),
              onLongPress: null,
            ),
            Divider(),
            ListTile(title: const Text('Devices discovery and connection')),
            SwitchListTile(
              title: const Text('Auto-try specific pin when pairing'),
              subtitle: const Text('Pin 1234'),
              value: _autoAcceptPairingRequests,
              onChanged: (bool value) {
                try {
                  setState(() {
                    _autoAcceptPairingRequests = value;
                  });
                  if (value) {
                    FlutterBluetoothSerial.instance.setPairingRequestHandler(
                        (BluetoothPairingRequest request) {
                      print("Trying to auto-pair with Pin 1234");
                      if (request.pairingVariant == PairingVariant.Pin) {
                        return Future.value("1234");
                      }
                      return Future.value(null);
                    });
                  } else {
                    FlutterBluetoothSerial.instance
                        .setPairingRequestHandler(null);
                  }
                } catch (e) {
                  print(e);
                }
              },
            ),
            ListTile(
              title: ElevatedButton(
                  child: const Text('Explore discovered devices'),
                  onPressed: () async {
                    try {
                      final BluetoothDevice? selectedDevice =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ScanPage();
                          },
                        ),
                      );

                      if (selectedDevice != null) {
                        print(
                            'Discovery -> selected ' + selectedDevice.address);
                      } else {
                        print('Discovery -> no device selected');
                      }
                    } catch (e) {
                      print(e);
                    }
                  }),
            ),
            ListTile(
              title: ElevatedButton(
                child: const Text('Connect to paired device to chat'),
                onPressed: () async {
                  try {
                    final BluetoothDevice? selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(
                              checkAvailability: false);
                        },
                      ),
                    );
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
